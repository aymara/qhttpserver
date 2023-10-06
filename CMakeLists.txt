project(qhttpserver)
cmake_minimum_required(VERSION 2.8)

if (NOT (${CMAKE_SYSTEM_NAME} STREQUAL "Windows"))
    if ("x${CMAKE_BUILD_TYPE}" STREQUAL "xRelease")
      set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -mtune=generic -march=x86-64")
    endif()
endif()

enable_testing()

include(SystemSpecificInformations.cmake)

message("System name is ${CMAKE_SYSTEM_NAME}")
if (NOT (${CMAKE_SYSTEM_NAME} STREQUAL "Windows"))
    message("Linux flags")

    include(CheckCXXCompilerFlag)

    CHECK_CXX_COMPILER_FLAG(-std=c++0x HAVE_STDCPP0X)
    CHECK_CXX_COMPILER_FLAG(-std=c++11 HAVE_STDCPP11)
    CHECK_CXX_COMPILER_FLAG(-std=c++14 HAVE_STDCPP14)
    CHECK_CXX_COMPILER_FLAG(-std=c++17 HAVE_STDCPP17)
    CHECK_CXX_COMPILER_FLAG(-fsanitize=undefined HAVE_SANITIZE_UNDEFINED)
    CHECK_CXX_COMPILER_FLAG(-fno-omit-frame-pointer HAVE_NO_OMIT_FRAME_POINTER)
    if (HAVE_NO_OMIT_FRAME_POINTER)
      set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fno-omit-frame-pointer")
    endif()


    if (HAVE_STDCPP17)
      message("C++17 supported")
      set(CMAKE_CXX_STANDARD 17)
      set(CMAKE_CXX_STANDARD_REQUIRED ON)
      set(CMAKE_CXX_EXTENSIONS OFF)
    elseif (HAVE_STDCPP14)
      message("C++14 supported")
      set(CMAKE_CXX_STANDARD 14)
      set(CMAKE_CXX_STANDARD_REQUIRED ON)
      set(CMAKE_CXX_EXTENSIONS OFF)
    elseif (HAVE_STDCPP11)
      message("C++11 supported")
      set(CMAKE_CXX_FLAGS "-std=c++11 -DBOOST_NO_HASH ${CMAKE_CXX_FLAGS}")
      CHECK_CXX_COMPILER_FLAG(-Wsuggest-override HAVE_SUGGEST_OVERRIDE)
      if (HAVE_SUGGEST_OVERRIDE)
#       set(CMAKE_CXX_FLAGS "-Wsuggest-override -Werror=suggest-override ${CMAKE_CXX_FLAGS}")
        set(CMAKE_CXX_FLAGS "-Wsuggest-override ${CMAKE_CXX_FLAGS}")
      endif()
    elseif (HAVE_STDCPP0X)
      message("C++0x supported")
      set(CMAKE_CXX_FLAGS "-std=c++0x -DBOOST_NO_HASH ${CMAKE_CXX_FLAGS}")
    else ()
      message("C++0x NOT supported")
      set(CMAKE_CXX_FLAGS "-DNO_STDCPP0X ${CMAKE_CXX_FLAGS}")
    endif ()
    set(CMAKE_CXX_FLAGS "-W -Wall ${CMAKE_CXX_FLAGS}")

    set(LIB_INSTALL_DIR "lib")

else (NOT (${CMAKE_SYSTEM_NAME} STREQUAL "Windows"))
  message("Windows flags")
  add_definitions(-D WIN32)

  # By default, do not warn when built on machines using only VS Express:
  IF(NOT DEFINED CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_NO_WARNINGS)
    SET(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_NO_WARNINGS ON)
  ENDIF(NOT DEFINED CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_NO_WARNINGS)

#   set(CMAKE_C_FLAGS "/Zc:wchar_t- /EHsc /GR ${CMAKE_C_FLAGS}")
#   set(CMAKE_CXX_FLAGS "/Zc:wchar_t- /EHsc /GR /W4 /MP /FAu ${CMAKE_CXX_FLAGS}")

  set(LIB_INSTALL_DIR "bin")

  install(FILES ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS}
    DESTINATION bin)

endif (NOT (${CMAKE_SYSTEM_NAME} STREQUAL "Windows"))


# Find*.cmake will be searched in the following dirs if not found in system dirs
set(CMAKE_MODULE_PATH
    "${CMAKE_SOURCE_DIR}/cmake/Modules" # for those available in this project
    "/usr/share/cmake/Modules" # for those available on the system
)

# find_path and find_library will search in these dirs too
set(CMAKE_PREFIX_PATH
    "${CMAKE_PREFIX_PATH}"
    "${CMAKE_INSTALL_PREFIX}"
)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -lpthread")

# It is necessary to define Qt5_INSTALL_DIR in your environment.
set(CMAKE_PREFIX_PATH  
  "$ENV{Qt5_INSTALL_DIR}"
  "${CMAKE_PREFIX_PATH}" 
)


add_definitions(-DQT_NO_KEYWORDS)
add_definitions(-DQT_DISABLE_DEPRECATED_BEFORE=0)
if (NOT (${CMAKE_SYSTEM_NAME} STREQUAL "Windows"))
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -DQT_DEPRECATED_WARNINGS")
else()
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DQT_COMPILING_QSTRING_COMPAT_CPP -D_SILENCE_STDEXT_HASH_DEPRECATION_WARNINGS")
endif()

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
find_package(Qt5 REQUIRED COMPONENTS Core Network)
set(Qt5_LIBRARIES  Qt5::Core Qt5::Network )
message("Found Qt5 ${Qt5Core_VERSION}")

message("\n\n\n{Qt5_LIBRARIES}=${Qt5_LIBRARIES} ")

if (${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
  get_target_property(QtCore_location Qt5::Core LOCATION)
  get_target_property(QtNetwork_location Qt5::Network LOCATION)
  install(FILES ${QtCore_location}
                ${QtNetwork_location}
          DESTINATION ${LIB_INSTALL_DIR})
endif ()


if(NOT DEFINED VERSION_RELEASE)
  set(VERSION_RELEASE "1")
endif()
configure_file(QHttpServerConfig-src.cmake QHttpServerConfig.cmake @ONLY)
INCLUDE(${CMAKE_CURRENT_BINARY_DIR}/QHttpServerConfig.cmake)


add_subdirectory(src)
add_subdirectory(examples)

########### documentation ###############

# add a target to generate API documentation with Doxygen
#find_package(Doxygen)
#if(DOXYGEN_FOUND)
#configure_file(${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile @ONLY)
#add_custom_target(doc
#${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile
#WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
#COMMENT "Generating API documentation with Doxygen" VERBATIM
#)
#endif(DOXYGEN_FOUND)

########### packaging ###############
# Specify additional runtime libraries that may not be detected. After 
# inclusion any detected libraries will be appended to this.
set(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS 
  ${QtCore_location}
  ${QtNetwork_location}
)

set(CMAKE_INSTALL_DEBUG_LIBRARIES TRUE)
set(MAKE_INSTALL_UCRT_LIBRARIES TRUE)
INCLUDE(InstallRequiredSystemLibraries)


set(CPACK_MONOLITHIC_INSTALL 1)
SET(CPACK_PACKAGE_NAME "qhttpserver")
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "A Qt HTTP server library")
SET(CPACK_PACKAGE_VENDOR "Nikhil Marathe <nsm.nikhil@gmail.com>")
SET(CPACK_PACKAGE_CONTACT "Gaël de Chalendar <kleag@free.fr>")
SET(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
SET(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
SET(CPACK_PACKAGE_VERSION_MAJOR "${QHTTPSERVER_VERSION_MAJOR}")
SET(CPACK_PACKAGE_VERSION_MINOR "${QHTTPSERVER_VERSION_MINOR}")
SET(CPACK_PACKAGE_VERSION_PATCH "${QHTTPSERVER_VERSION_RELEASE}")
SET(CPACK_PACKAGE_VERSION "${QHTTPSERVER_VERSION}")
SET(CPACK_PACKAGE_INSTALL_DIRECTORY "qhttpserver-${QHTTPSERVER_VERSION}")
#SET(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES64")
#SET(CPACK_NSIS_MODIFY_PATH "ON")
#SET(CPACK_STRIP_FILES "")
#SET(CPACK_SOURCE_STRIP_FILES "")
#SET(CPACK_DEBIAN_PACKAGE_SHLIBDEPS OFF)
#SET(CPACK_DEBIAN_PACKAGE_GENERATE_SHLIBS OFF)
SET(CPACK_GENERATOR ${SPECIFIC_SYSTEM_PREFERED_CPACK_GENERATOR})
# set(CPACK_RPM_PACKAGE_REQUIRES "qt5 >= 5.2")
# SET(CPACK_DEBIAN_PACKAGE_DEPENDS "")

SET(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}")

INCLUDE(CPack)

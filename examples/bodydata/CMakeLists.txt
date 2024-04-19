include_directories(BEFORE ${CMAKE_SOURCE_DIR}/src)

add_definitions( -DQHTTPSERVER_EXPORT )

SET(œ_EXE_SRCS 
  bodydata.cpp
  )

add_executable(bodydata_server ${bodydata_EXE_SRCS})

target_link_libraries(bodydata_server qhttpserver ${Qt6_LIBRARIES})

add_test(
  NAME bodydata_Test
  COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/test/bodydata.sh ${CMAKE_CURRENT_BINARY_DIR}
)

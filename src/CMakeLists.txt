include_directories(BEFORE ${CMAKE_SOURCE_DIR}/http-parser)

add_definitions( -DQHTTPSERVER_EXPORT )

########### next target ###############

SET(qhttpserver_LIB_SRCS 
  qhttpconnection.cpp
  qhttprequest.cpp
  qhttpresponse.cpp
  qhttpserver.cpp
  ../http-parser/http_parser.c
  ../http-parser/url_parser.c
)

add_library(qhttpserver SHARED ${qhttpserver_LIB_SRCS})

target_link_libraries(qhttpserver ${Qt5_LIBRARIES})

install(TARGETS qhttpserver DESTINATION ${LIB_INSTALL_DIR})

########### install files ###############
install(FILES
    qhttpconnection.h
    qhttprequest.h
    qhttpresponse.h
    qhttpserver.h
    qhttpserverapi.h
    qhttpserverfwd.h
  DESTINATION include)

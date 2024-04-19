include_directories(BEFORE ${CMAKE_SOURCE_DIR}/src)

add_definitions( -DQHTTPSERVER_EXPORT )

SET(helloworld_EXE_SRCS 
  helloworld.cpp
  )

add_executable(helloworld_server ${helloworld_EXE_SRCS})

target_link_libraries(helloworld_server qhttpserver ${Qt6_LIBRARIES})

add_test(
  NAME helloworld_Test
  COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/test/helloworld.sh ${CMAKE_CURRENT_BINARY_DIR}
)

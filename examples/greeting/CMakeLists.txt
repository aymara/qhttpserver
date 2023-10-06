include_directories(BEFORE ${CMAKE_SOURCE_DIR}/src)

add_definitions( -DQHTTPSERVER_EXPORT )

SET(greeting_EXE_SRCS 
  greeting.cpp
  )

add_executable(greeting_server ${greeting_EXE_SRCS})

target_link_libraries(greeting_server qhttpserver ${Qt5_LIBRARIES})

add_test(
  NAME greeting_Test
  COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/test/greeting.sh ${CMAKE_CURRENT_BINARY_DIR}
)

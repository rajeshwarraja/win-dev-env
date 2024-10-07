project(${PROJECT_NAME}.Cpp LANGUAGES CXX)

file(GLOB SOURCES "src/*.cpp")

add_executable(${PROJECT_NAME} ${SOURCES})

add_test(NAME ${PROJECT_NAME} COMMAND ${PROJECT_NAME})
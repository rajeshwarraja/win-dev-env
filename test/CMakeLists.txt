project(${PROJECT_NAME}.Test)

find_program(NUGET nuget REQUIRED)
if(NOT NUGET)
    message(FATAL_ERROR "NuGet not found!")
else()
    message(STATUS "Found NuGet: ${NUGET}")
endif()

find_program(NINJA ninja REQUIRED)
if(NOT NINJA)
    message(FATAL_ERROR "Ninja not found!")
else()
    message(STATUS "Found Ninja: ${NINJA}")
endif()

find_program(CONAN conan REQUIRED)
if(NOT CONAN)
    message(FATAL_ERROR "Conan not found!")
else()
    message(STATUS "Found Conan: ${CONAN}")
endif()

find_program(GIT git REQUIRED)
if(NOT GIT)
    message(FATAL_ERROR "Git not found!")
else()
    message(STATUS "Found Git: ${GIT}")
endif()


add_subdirectory(cpp)
add_subdirectory(dot_net)
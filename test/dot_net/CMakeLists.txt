project(${PROJECT_NAME}.CSharp LANGUAGES CSharp)

include(CSharpUtilities)

add_executable(${PROJECT_NAME}
    "src/Program.cs"
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    LINKER_LANGUAGE CSharp
    VS_DOTNET_TARGET_FRAMEWORK_VERSION "v4.8"
    VS_DOTNET_REFERENCES
        "Microsoft.CSharp;
        System;
        System.Core;
        System.Data;
        System.Data.DataSetExtensions"
)

add_test(NAME ${PROJECT_NAME} COMMAND ${PROJECT_NAME})

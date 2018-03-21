cmake_minimum_required(VERSION 2.8.12)
project(Trinity LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt5 COMPONENTS Core Quick Widgets REQUIRED)

add_executable(${PROJECT_NAME}
    src/main.cpp
    qml.qrc
    src/eventmodel.cpp
    include/eventmodel.h
    src/matrixcore.cpp
    include/matrixcore.h
    include/network.h
    include/requestsender.h
    include/room.h
    include/roomlistmodel.h
    src/roomlistmodel.cpp
    include/desktop.h
    include/membermodel.h
    src/membermodel.cpp
    include/community.h
    include/communitylistmodel.h
    src/communitylistmodel.cpp
    src/roomlistsortmodel.cpp
    include/roomlistsortmodel.h
    include/emotelistmodel.h
    src/emotelistmodel.cpp
    include/emote.h)

target_link_libraries(${PROJECT_NAME} Qt5::Core Qt5::Quick Qt5::Widgets cmark)
target_include_directories(${PROJECT_NAME} PRIVATE include)

install(TARGETS ${PROJECT_NAME} DESTINATION bin)

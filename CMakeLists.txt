cmake_minimum_required(VERSION 2.8.12)
project(Trinity LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt5 COMPONENTS Core Quick Widgets REQUIRED)

add_executable(${PROJECT_NAME}
    main.cpp
    qml.qrc
    eventmodel.cpp
    eventmodel.h
    matrixcore.cpp
    matrixcore.h
    network.h
    requestsender.h
    room.h
    roomlistmodel.h
    roomlistmodel.cpp
    desktop.h
    membermodel.h
    membermodel.cpp
    community.h
    communitylistmodel.h
    communitylistmodel.cpp
    roomlistsortmodel.cpp
    roomlistsortmodel.h
    emotelistmodel.h
    emotelistmodel.cpp
    emote.h)

target_link_libraries(${PROJECT_NAME} Qt5::Core Qt5::Quick Qt5::Widgets cmark)

install(TARGETS ${PROJECT_NAME} DESTINATION bin)

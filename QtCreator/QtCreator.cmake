find_path(QT_CREATOR_SRC "qtcreator.pro" DOC "Path to Qt Creator source")

include(ExternalProject)

if(NOT QT_CREATOR_SRC)	
	ExternalProject_Add(
		QtCreator
		URL "http://download.qt-project.org/official_releases/qtcreator/3.3/3.3.0/qt-creator-opensource-src-3.3.0.tar.gz"
		UPDATE_COMMAND "${CMAKE_COMMAND}" -E copy "${CMAKE_SOURCE_DIR}/QtCreator/CMakeLists.txt" .
		CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
               -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG:PATH=Debug
               -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE:PATH=Release
               -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
		INSTALL_COMMAND "")
else()
	ExternalProject_Add(
		QtCreator
		SOURCE_DIR ${QT_CREATOR_SRC}
		UPDATE_COMMAND "${CMAKE_COMMAND}" -E copy "${CMAKE_SOURCE_DIR}/QtCreator/CMakeLists.txt" .
		CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
               -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG:PATH=Debug
               -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE:PATH=Release
               -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
		INSTALL_COMMAND "")
endif()

ExternalProject_Get_Property(QtCreator SOURCE_DIR)
ExternalProject_Get_Property(QtCreator BINARY_DIR)

add_library(qmljs STATIC IMPORTED)
add_dependencies(qmljs QtCreator)

set_property(TARGET qmljs PROPERTY IMPORTED_LOCATION_DEBUG "${BINARY_DIR}/Debug/${CMAKE_STATIC_LIBRARY_PREFIX}qmljs${CMAKE_STATIC_LIBRARY_SUFFIX}")
set_property(TARGET qmljs PROPERTY IMPORTED_LOCATION_RELEASE "${BINARY_DIR}/Release/${CMAKE_STATIC_LIBRARY_PREFIX}qmljs${CMAKE_STATIC_LIBRARY_SUFFIX}")

find_package(Qt5Widgets REQUIRED)
find_package(Qt5Network REQUIRED)
find_package(Qt5Concurrent REQUIRED)
find_package(Qt5Script REQUIRED)
find_package(Qt5Xml REQUIRED)

set_property(TARGET qmljs PROPERTY INTERFACE_LINK_LIBRARIES
	"${BINARY_DIR}/$<CONFIG>/${CMAKE_STATIC_LIBRARY_PREFIX}cplusplus${CMAKE_STATIC_LIBRARY_SUFFIX}"
	"${BINARY_DIR}/$<CONFIG>/${CMAKE_STATIC_LIBRARY_PREFIX}utils${CMAKE_STATIC_LIBRARY_SUFFIX}"
	"${BINARY_DIR}/$<CONFIG>/${CMAKE_STATIC_LIBRARY_PREFIX}languageutils${CMAKE_STATIC_LIBRARY_SUFFIX}"
	Qt5::Widgets Qt5::Script Qt5::Xml Qt5::Network Qt5::Concurrent)

file(MAKE_DIRECTORY "${SOURCE_DIR}/src/libs/")
file(MAKE_DIRECTORY "${SOURCE_DIR}/src/libs/3rdparty/")

set_property(TARGET qmljs PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${SOURCE_DIR}/src/libs/3rdparty/" "${SOURCE_DIR}/src/libs/")
set_property(TARGET qmljs PROPERTY INTERFACE_COMPILE_DEFINITIONS 
	"QML_BUILD_STATIC_LIB" "QT_CREATOR" "_CRT_SECURE_NO_WARNINGS" "QTCREATOR_UTILS_STATIC_LIB" "CPLUSPLUS_BUILD_LIB" "LANGUAGEUTILS_BUILD_STATIC_LIB")

# Toolchain Definitions

# set (CMAKE_FIND_USE_CMAKE_ENVIRONMENT_PATH FALSE)   # defined in common.cmake

if (NOT _common_cmake_included)
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/common.cmake")
        include (${CMAKE_CURRENT_LIST_DIR}/common.cmake)
    endif()
endif ()
if (NOT _shared_definitions)
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/shared-definitions.cmake")
        include (${CMAKE_CURRENT_LIST_DIR}/shared-definitions.cmake)
    endif()
endif ()
if (NOT _build_shard_libs)
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/build-shard.cmake")
        include (${CMAKE_CURRENT_LIST_DIR}/build-shard.cmake)
    endif()
endif ()
if (NOT _shared_output)
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/shared-output.cmake")
        include (${CMAKE_CURRENT_LIST_DIR}/shared-output.cmake)
    endif()
endif ()

list (APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_LIST_DIR}")
list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")

message_format (STATUS "${lead_mark_location}" "compiler option" "initial CMAKE_C_FLAGS"   "=" "${CMAKE_C_FLAGS}")
message_format (STATUS "${lead_mark_location}" "compiler option" "initial CMAKE_CXX_FLAGS" "=" "${CMAKE_CXX_FLAGS}")

# set (compiler_option_defined ON CACHE BOOL PARENT_SCOPE FORCE)    # add_definitions (-Dcompiler_option_defined)

# # set (CMAKE_C_FLAGS "-Wall -std=c99")        # initialization
# set (CMAKE_C_FLAGS "-Wall -std=c99 -flto")    # initialization
# # set (CMAKE_CXX_FLAGS "-Wall")               # initialization
# set (CMAKE_CXX_FLAGS "-Wall -flto")           # initialization

# # if !defined(QT_BOOTSTRAPPED) && defined(QT_REDUCE_RELOCATIONS) && defined(__ELF__) && \
# (!defined(__PIC__) || (defined(__PIE__) && defined(Q_CC_GNU) && Q_CC_GNU >= 500))
# # error "You must build your code with position independent code if Qt was built with -reduce-relocations. "\
#      "Compile your code with -fPIC (-fPIE is not enough)."
# # endif

# set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIE")
# add_compile_definitions (-fPIC)
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
add_compile_options  (-fPIC)

# https://stackoverflow.com/questions/17925648/too-many-errors-emitted-stopping-now-how-to-increase-or-remove-the-limit/21102127
set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -ferror-limit=0")
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ferror-limit=0")
add_compile_options (-ferror-limit=0)

set (CMAKE_CXX_STANDARD_REQUIRED ON)

# https://en.wikipedia.org/wiki/C%2B%2B20
# c++20 for clang >= 10, c++20 and gnu++20 for gcc >= 10
include (CheckCXXCompilerFlag)
# set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}  -pthread -std=c++2a -std=gnu++2a")
# Check for standard to use
# check_cxx_compiler_flag (-std=c++2a HAVE_FLAG_STD_CXX20)
check_cxx_compiler_flag (-std=c++20 HAVE_FLAG_STD_CXX20)
if (HAVE_FLAG_STD_CXX20)
    # Have -std=c++20, use it
    # message_format (STATUS "${lead_mark_location}" "compiler option" "Set up cpp 2a support" "=" "${HAVE_FLAG_STD_CXX20}")
    message_format (STATUS "${lead_mark_location}" "compiler option" "Set up cpp 20 support" "=" "${HAVE_FLAG_STD_CXX20}")
    set (CMAKE_CXX_STANDARD 20)
    # set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread -std=gnu++2a -std=c++2a")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread -std=c++20")
    # add_definitions(-std=c++2a)
    if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        add_compile_options (-pthread -std=c++20)
    elseif (CMAKE_CXX_COMPILER_ID MATCHES "GNU")
        add_compile_options (-pthread -std=gnu++20)
    elseif (CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
        add_compile_options (/std:c++latest)    # /std:c++20
    endif ()
else ()
    check_cxx_compiler_flag(-std=c++17 HAVE_FLAG_STD_CXX17)
    if (HAVE_FLAG_STD_CXX17)
        # Have -std=c++17, use it
        message_format (STATUS "${lead_mark_location}" "compiler option" "Set cpp 17 support" "=" "${HAVE_FLAG_STD_CXX17}")
        set (CMAKE_CXX_STANDARD 17)
        # set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread -std=gnu++17 -std=c++17")
        set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread -std=c++17")
        if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
            add_compile_options (-pthread -std=c++17)
        elseif (CMAKE_CXX_COMPILER_ID MATCHES "GNU")
            add_compile_options (-pthread -std=gnu++17)
        elseif (CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
            add_compile_options (/std:c++17)
        endif ()
    else ()
        # And so on and on...
    endif ()
endif ()

set (CMAKE_THREAD_LIBS_INIT         "-lpthread")
set (CMAKE_HAVE_THREADS_LIBRARY     1)
set (CMAKE_USE_WIN32_THREADS_INIT   0)
set (CMAKE_USE_PTHREADS_INIT        1)
set (THREADS_PREFER_PTHREAD_FLAG    ON) # set(THREADS_PREFER_PTHREAD_FLAG TRUE)

find_package (Threads REQUIRED)
message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_THREAD_LIBS_INIT" "=" "${CMAKE_THREAD_LIBS_INIT}" )






# output DEPENDENCIES_INCLUDE_DIRS
# output DEPENDENCIES_LIBRARIES
macro(compiler_options_setting DEPENDENCIES_INCLUDE_DIRS DEPENDENCIES_LIBRARY_DIRS DEPENDENCIES_LIBRARIES)
    string (REPLACE ";" " " DEPENDENCIES_INCLUDE_DIRS_STRING "${${DEPENDENCIES_INCLUDE_DIRS}}")
    string (REPLACE ";" " " DEPENDENCIES_LIBRARY_DIRS_STRING "${${DEPENDENCIES_LIBRARY_DIRS}}")
    string (REPLACE ";" " " DEPENDENCIES_LIBRARIES_STRING    "${${DEPENDENCIES_LIBRARIES}}")

    set (DEPENDENCIES_LIBRARIES_FLAGS "")
    foreach (lib ${${DEPENDENCIES_LIBRARIES}})
        set (DEPENDENCIES_LIBRARIES_FLAGS "${DEPENDENCIES_LIBRARIES_FLAGS} -l${lib}")
    endforeach ()

    # https://stackoverflow.com/questions/55921707/setting-path-to-clang-library-in-cmake
    # https://stackoverflow.com/questions/10046114/in-cmake-how-can-i-test-if-the-compiler-is-clang
    string (FIND "${CMAKE_CXX_COMPILER}" "clang++" clangplusplus_index)

    if ((NOT ${clangplusplus_index} EQUAL -1 ) AND (CMAKE_CXX_COMPILER_ID MATCHES "Clang"))

        # https://android.googlesource.com/platform/external/libcxx/+/8260b5d56f6880a29b57f73b7f4866e47e9e4818/CMakeLists.txt
        # https://divine.fi.muni.cz/2017/divine4/divine4/runtime/libcxx/CMakeLists.txt

        # _____________________________________________________
        # clang ports use the old/dated libstdc++ from the host (gcc-4.2 based)
        # https://trac.macports.org/ticket/34288
        # _____________________________________________________

        # option(LIBCXX_HAS_MUSL_LIBC "Build libc++ with support for the Musl C library" OFF)
        # option(LIBCXX_INSTALL_HEADERS "Install the libc++ headers." ON)
        # option(LIBCXX_INSTALL_LIBRARY "Install the libc++ library." ON)
        # option(LIBCXX_INSTALL_SUPPORT_HEADERS "Install libc++ support headers." ON)

        add_definitions (-DLIBCXX_INSTALL_EXPERIMENTAL_LIBRARY=YES)
        add_definitions (-DLIBCXX_INSTALL_FUNDAMENTALS_LIBRARY=YES)

        message_format (STATUS "${lead_mark_location}" "compiler option" "LIBCXX_HAS_MUSL_LIBC" "=" "${LIBCXX_HAS_MUSL_LIBC}" )
        message_format (STATUS "${lead_mark_location}" "compiler option" "LIBCXX_INSTALL_SUPPORT_HEADERS" "=" "${LIBCXX_INSTALL_SUPPORT_HEADERS}" )
        message_format (STATUS "${lead_mark_location}" "compiler option" "LIBCXX_TARGETING_CLANG_CL" "=" "${LIBCXX_TARGETING_CLANG_CL}" )

        # cmake expecting the following filenames
        # LibClangConfig.cmake↴
        # clang-config.cmake↴
        include (llvm-config)
        include (clang-config)
        include (libclang-config)

        list (REMOVE_DUPLICATES CMAKE_MODULE_PATH)
        foreach(module_dir ${CMAKE_MODULE_PATH})
            #    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" " CMAKE_MODULE_PATH     " "="  "${CMAKE_MODULE_PATH}")
            message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} CMAKE_MODULE_PATH" "module_dir" "="  "${module_dir}")
        endforeach()

        if (NOT DEFINED LLVM_INSTALL_PREFIX)
            message_format (FATAL_ERROR "${lead_mark_location}" "compiler option" "LLVM_INSTALL_PREFIX NOT DEFINED" "" "")
        endif ()

        if (NOT DEFINED CLANG_INSTALL_PREFIX)
            message_format (FATAL_ERROR "${lead_mark_location}" "compiler option" "CLANG_INSTALL_PREFIX NOT DEFINED" "" "")
        endif ()

        message_format (STATUS "${lead_mark_location}" "compiler option" "CLANG_INSTALL_PREFIX"    "=" "${CLANG_INSTALL_PREFIX}")

        if (NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
            message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_C_COMPILER"   "=" "${CMAKE_C_COMPILER}")
            message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_CXX_COMPILER" "=" "${CMAKE_CXX_COMPILER}")
            if (DEFINED CLANG_INSTALL_PREFIX)
                set (CMAKE_C_COMPILER   "${CLANG_INSTALL_PREFIX}/bin/clang"    CACHE STRING "C compiler" FORCE)
                set (CMAKE_CXX_COMPILER "${CLANG_INSTALL_PREFIX}/bin/clang++"  CACHE STRING "C++ compiler" FORCE)
            endif ()
        endif ()

        set(CMAKE_CXX_EXTENSIONS OFF)   # gnu++
        # import LLVM CMake functions
        include(LLVMConfig)
        include(AddLLVM)
        include(ClangConfig)
        # Find CMake file for Clang
        if (NOT DEFINED LLVM)
            # find_package (Clang REQUIRED)
            find_package(LLVM REQUIRED CONFIG)
        endif ()
        enable_language(CXX)
        # message_format (STATUS "${lead_mark_location}" "compiler option" "Clang support included.")
        # Add path to LLVM modules

        # https://github.com/patrykstefanski/dc-lang/blob/master/CMakeLists.txt
        message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
        include_directories(${LLVM_INCLUDE_DIRS})
        add_definitions(${LLVM_DEFINITIONS})
        #if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        # # using regular Clang or AppleClang
        #endif ()
        if (NOT DEFINED Clang)
            find_package(Clang REQUIRED CONFIG)
            find_package(Clang REQUIRED COMPONENTS libClang clangTooling CONFIG)
        endif ()

        # include (${CMAKE_CURRENT_LIST_DIR}/FindLibClang.cmake)
        if (NOT LibClang_FOUND)
            find_package(LibClang REQUIRED CONFIG)
        endif ()
        # get_target_property (LibClang_LIBRARIES LibClang IMPORTED_LOCATION)
        if (LibClang_FOUND)
            message_format (STATUS "${lead_mark_location}" "compiler option" "LIBCLANG_CXXFLAGS" "=" "${LIBCLANG_CXXFLAGS}")
            set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${LIBCLANG_CXXFLAGS}")
            message_format (STATUS "${lead_mark_location}" "compiler option" "LIBCLANG_LIBRARY"      "=" "${LIBCLANG_LIBRARY}")
            message_format (STATUS "${lead_mark_location}" "compiler option" "LibClang_LIBRARY"      "=" "${LibClang_LIBRARY}")
            message_format (STATUS "${lead_mark_location}" "compiler option" "LibClang_LIBRARIES"    "=" "${LibClang_LIBRARIES}")
            message_format (STATUS "${lead_mark_location}" "compiler option" "LIBCLANG_LIBRARIES"    "=" "${LIBCLANG_LIBRARIES}")
            message_format (STATUS "${lead_mark_location}" "compiler option" "LibClang_INCLUDE_DIRS" "=" "${libClang_INCLUDE_DIRS}")
            message_format (STATUS "${lead_mark_location}" "compiler option" "LibClang_INCLUDE_DIR"  "=" "${LibClang_INCLUDE_DIR}")
            message_format (STATUS "${lead_mark_location}" "compiler option" "CLANG_LIBS"            "=" "${CLANG_LIBS}")
        endif ()
        if (DEFINED clangTooling)
            get_target_property (clangTooling_LIBRARY clangTooling IMPORTED_LOCATION)
        endif ()
        if (DEFINED libClang)
            get_target_property (libClang_LIBRARY libClang IMPORTED_LOCATION)
        endif ()
        if (DEFINED Clang)
            include_directories(${CLANG_INCLUDE_DIRS})
            add_definitions(${CLANG_DEFINITIONS})
            message_format (STATUS "${lead_mark_location}" "compiler option" "Clang support included." "" "")
            message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_C_COMPILER"        "=" "${CMAKE_C_COMPILER}")
            message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_CXX_COMPILER"      "=" "${CMAKE_CXX_COMPILER}")
            message_format (STATUS "${lead_mark_location}" "compiler option" "clangTooling_LIBRARY"    "=" "${clangTooling_LIBRARY}")  # clangTooling_LIBRARY-NOTFOUND
            message_format (STATUS "${lead_mark_location}" "compiler option" "libClang_LIBRARY"        "=" "${libClang_LIBRARY}")
            message_format (STATUS "${lead_mark_location}" "compiler option" "libClang_INCLUDE_DIRS"   "=" "${libClang_INCLUDE_DIRS}")
        endif ()



        # https://stackoverflow.com/questions/52931852/how-to-convert-llvm-clang-command-line-to-cmake-config
        if (NOT LLVM_ENABLE_RTTI)
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-rtti")
            add_compile_options (-fno-rtti)
        else ()
            set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -frtti")
            add_compile_options (-frtti)
        endif()

        # https://stackoverflow.com/questions/43969219/error-libc-so-undefined-reference-to-unwind-getregionstart
        # https://stackoverflow.com/questions/7031126/switching-between-gcc-and-clang-llvm-using-cmake
        set (CMAKE_C_COMPILER               "${CLANG_INSTALL_PREFIX}/bin/clang")
        string (FIND "${CMAKE_C_FLAGS}" "-Wall -std=c99" initial_index)
        if (${initial_index} EQUAL -1)
            set (CMAKE_C_FLAGS                  "${CMAKE_C_FLAGS} -Wall -std=c99")
        endif ()

        set (CMAKE_C_FLAGS                  "${CMAKE_C_FLAGS} -flto")
        set (CMAKE_C_FLAGS_DEBUG            "-g")                # set (CMAKE_C_FLAGS_DEBUG            "${CMAKE_C_FLAGS_DEBUG} -g")
        set (CMAKE_C_FLAGS_MINSIZEREL       "-Os -DNDEBUG")        # set (CMAKE_C_FLAGS_MINSIZEREL       "${CMAKE_C_FLAGS_MINSIZEREL} -Os -DNDEBUG")
        set (CMAKE_C_FLAGS_RELEASE          "-O4 -DNDEBUG")        # set (CMAKE_C_FLAGS_RELEASE          "${CMAKE_C_FLAGS_RELEASE} -O4 -DNDEBUG")
        set (CMAKE_C_FLAGS_RELWITHDEBINFO   "-O2 -g")            # set (CMAKE_C_FLAGS_RELWITHDEBINFO   "${CMAKE_C_FLAGS_RELWITHDEBINFO} -O2 -g")

        set (CMAKE_CXX_COMPILER             "${CLANG_INSTALL_PREFIX}/bin/clang++")
        string (FIND "${CMAKE_CXX_FLAGS}" "-Wall" initial_index)
        if (${initial_index} EQUAL -1)
            set (CMAKE_CXX_FLAGS                "${CMAKE_CXX_FLAGS} -Wall")
        endif ()

        set (CMAKE_CXX_FLAGS                "${CMAKE_CXX_FLAGS} -flto")
        set (CMAKE_CXX_FLAGS_DEBUG          "-g")                # set (CMAKE_CXX_FLAGS_DEBUG          "${CMAKE_CXX_FLAGS_DEBUG} -g")
        set (CMAKE_CXX_FLAGS_MINSIZEREL     "-Os -DNDEBUG")        # set (CMAKE_CXX_FLAGS_MINSIZEREL     "${CMAKE_CXX_FLAGS_MINSIZEREL} -Os -DNDEBUG")
        set (CMAKE_CXX_FLAGS_RELEASE        "-O4 -DNDEBUG")        # set (CMAKE_CXX_FLAGS_RELEASE        "${CMAKE_CXX_FLAGS_RELEASE} -O4 -DNDEBUG")
        set (CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 -g")            # set (CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -O2 -g")

        # https://gitlab.kitware.com/cmake/community/-/wikis/doc/cmake/Useful-Variables
        set (CMAKE_C_FLAGS_DISTRIBUTION     "-O3")
        set (CMAKE_CXX_FLAGS_DISTRIBUTION   "-O3")


        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_LINKER" "=" "${CMAKE_LINKER}")
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CLANG_DEFAULT_LINKER" "=" "${CLANG_DEFAULT_LINKER}")
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_LINK_EXECUTABLE" "=" "${CMAKE_LINK_EXECUTABLE}")

        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_AR" "=" "${CMAKE_AR}") # /usr/bin/ar
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_AS" "=" "${CMAKE_AS}")
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_NM" "=" "${CMAKE_NM}") # /usr/bin/nm
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CLANG_DEFAULT_RTLIB" "=" "${CLANG_DEFAULT_RTLIB}")
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "compiler-rt" "=" "${compiler-rt}")

        set (CLANG_DEFAULT_RTLIB             compiler-rt)
        set (CLANG_ENABLE_BOOTSTRAP          ON)
        set (LIBCXX_USE_COMPILER_RT          ON)
        set (LIBUNWIND_USE_COMPILER_RT       ON)
        set (LLVM_ENABLE_LLD                 ON)
        set (LLVM_ENABLE_LIBCXX              ON)
        set (LIBCXXABI_USE_LLVM_UNWINDER     ON)
        set (LIBCXXABI_USE_COMPILER_RT       ON)
        set (BOOTSTRAP_LLVM_ENABLE_LLD)
        set (CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)

        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_OBJDUMP" "=" "${CMAKE_OBJDUMP}")   # /usr/bin/objdump
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_RANLIB" "=" "${CMAKE_RANLIB}")     # /usr/bin/ranlib
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_CXX_COMPILER_AR" "=" "${CMAKE_CXX_COMPILER_AR}") # /usr/bin/llvm-ar
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_CXX_COMPILER_OBJDUMP" "=" "${CMAKE_CXX_COMPILER_OBJDUMP}")  #
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_CXX_COMPILER_RANLIB" "=" "${CMAKE_CXX_COMPILER_RANLIB}")    # /usr/bin/llvm-ranlib
        # set (CMAKE_AR                        "${CLANG_INSTALL_PREFIX}/bin/llvm-ar")
        set (CMAKE_AS       "${CLANG_INSTALL_PREFIX}/bin/llvm-as")
        set (CMAKE_NM       "${CLANG_INSTALL_PREFIX}/bin/llvm-nm")
        set (CMAKE_OBJDUMP  "${CLANG_INSTALL_PREFIX}/bin/llvm-objdump")

        set (CMAKE_AR        ${CMAKE_CXX_COMPILER_AR} CACHE PATH "AR" FORCE)
        set (CMAKE_RANLIB    ${CMAKE_CXX_COMPILER_RANLIB} CACHE PATH "RANLIB" FORCE)
        # https://linux.die.net/man/1/llvm-ranlib
        # set (CMAKE_RANLIB  "${CLANG_INSTALL_PREFIX}/bin/llvm-ranlib")   # /usr/bin/llvm-ranlib -> llvm-ar

        add_definitions(${LLVM_DEFINITIONS})
        add_definitions(${CLANG_DEFINITIONS})
        list (APPEND ${DEPENDENCIES_LIBRARY_DIRS} "${LLVM_LIBRARY_DIRS}")



        # https://github.com/NixOS/nixpkgs/issues/126583
        # LLVM: Invalid value for LLVM_INSTALL_PREFIX due to incorrect number of get_filename_component lines in LLVMConfig.cmake #126583
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "LLVM_INSTALL_PREFIX" "=" "${LLVM_INSTALL_PREFIX}")
        llvm_map_components_to_libnames(REQ_LLVM_LIBRARIES jit native)

        # Add path to LLVM modules
        list (APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "Clang_DIR" "=" "${Clang_DIR}")  # /usr/lib/cmake/clang

        # message_format (STATUS "${lead_mark_location}" "compiler option" "LLVM_DIR " "=" "${LLVM_DIR}")

        set(echo_vars)
        set(echo_vars_value "${echo_vars}")
        # result by find_package(LLVM REQUIRED CONFIG)
        list(APPEND echo_vars
            "LLVM_INSTALL_PREFIX"
            "LLVM_DIR"
            "LLVM_PACKAGE_VERSION"
            "LLVM_INCLUDE_DIRS"
            "LLVM_INCLUDE_DIR"
            "LLVM_DEFINITIONS"
            )
        list(APPEND echo_vars_value
            "${LLVM_INSTALL_PREFIX}"
            "${LLVM_DIR}"
            "${LLVM_PACKAGE_VERSION}"
            "${LLVM_INCLUDE_DIRS}"
            "${LLVM_INCLUDE_DIR}"
            "${LLVM_DEFINITIONS}"
            )

        # detect environment
        list(APPEND echo_vars
            "CMAKE_C_COMPILER_ID"
            "CMAKE_C_STANDARD"
            "CMAKE_CXX_COMPILER_ID"
            "CMAKE_CXX_STANDARD"
            "CMAKE_CXX_FLAGS"
            "CMAKE_GNUtoMS"
            "CMAKE_SYSTEM_NAME"
            "CMAKE_COMPILER_IS_GNUC"
            "CMAKE_COMPILER_IS_GNUCXX"
            "CMAKE_COMPILER_IS_CLANG"
            "CMAKE_COMPILER_IS_MINGW"
            "CMAKE_COMPILER_IS_CYGWIN"
            "CMAKE_GNU_COMPILER_ID"
            "CMAKE_CLANG_COMPILER_ID"
            )
        list(APPEND echo_vars_value
            "${CMAKE_C_COMPILER_ID}"
            "${CMAKE_C_STANDARD}"
            "${CMAKE_CXX_COMPILER_ID}"
            "${CMAKE_CXX_STANDARD}"
            "${CMAKE_CXX_FLAGS}"
            "${CMAKE_GNUtoMS}"
            "${CMAKE_SYSTEM_NAME}"
            "${CMAKE_COMPILER_IS_GNUC}"
            "${CMAKE_COMPILER_IS_GNUCXX}"
            "${CMAKE_COMPILER_IS_CLANG}"
            "${CMAKE_COMPILER_IS_MINGW}"
            "${CMAKE_COMPILER_IS_CYGWIN}"
            "${CMAKE_GNU_COMPILER_ID}"
            "${CMAKE_CLANG_COMPILER_ID}"
            )


        list (LENGTH echo_vars count)
        math (EXPR count "${count}-1")
        foreach(i RANGE ${count})
            list(GET echo_vars ${i} s1)
            list(GET echo_vars_value ${i} s2)
            # string (LENGTH ${s1} module_length)
            # math (EXPR tab_count1 "(40 - ${module_length})" OUTPUT_FORMAT DECIMAL)
            # set (tab_display1 "")
            # foreach(i RANGE ${tab_count1})
            #  set (tab_display1 "${tab_display1} ")
            # endforeach()
            # message_format (STATUS "${lead_mark_location}" "compiler option" "${s1} ${tab_display1}= ${s2}")
            message_format (STATUS "${lead_mark_location}" "compiler option" "${s1}" "=" "${s2}")
        endforeach()

        # message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_MODULE_PATH " "=" "${CMAKE_MODULE_PATH}")

        # # import LLVM CMake functions
        # include(AddLLVM.cmake)
        # include(CMakeTestCCompiler.cmake)
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_C_COMPILER" "=" "${CMAKE_C_COMPILER}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_CXX_COMPILER" "=" "${CMAKE_CXX_COMPILER}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "LLVM_INCLUDE_DIRS" "=" "${LLVM_INCLUDE_DIRS}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "LLVM_INCLUDE_DIR" "=" "${LLVM_INCLUDE_DIR}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "LLVM_LIBRARY_DIRS" "=" "${LLVM_LIBRARY_DIRS}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "LLVM_LD_FLAGS_STRING" "=" "${LLVM_LD_FLAGS_STRING}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CLANG_INCLUDE_DIRS" "=" "${CLANG_INCLUDE_DIRS}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CLANG_LIBS" "=" "${CLANG_LIBS}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "LLVM_LIBS" "=" "${LLVM_LIBS}")

        # # https://stackoverflow.com/questions/37969440/clang-openmp-and-cmake
        # # export C_INCLUDE_PATH=$(llvm-config --includedir)
        # # export LIBRARY_PATH=$(llvm-config --libdir)
        #
        # # set (C_INCLUDE_PATH             "${C_INCLUDE_PATH} $(llvm-config --includedir)")
        # list (APPEND C_INCLUDE_PATH      "${LLVM_INCLUDE_DIRS}")
        # list (APPEND C_INCLUDE_PATH      "${CLANG_INCLUDE_DIRS}")
        # # set (CPLUS_INCLUDE_PATH         "${CPLUS_INCLUDE_PATH} $(llvm-config --includedir)")
        # list (APPEND CPLUS_INCLUDE_PATH  "${LLVM_INCLUDE_DIRS}")
        # list (APPEND CPLUS_INCLUDE_PATH  "${CLANG_INCLUDE_DIRS}")
        # list (APPEND LIBRARY_PATH        "${LLVM_LIBRARY_DIRS}")  # set (LIBRARY_PATH "${LIBRARY_PATH} $(llvm-config --libdir)")
        # list(REMOVE_DUPLICATES C_INCLUDE_PATH)
        # list(REMOVE_DUPLICATES CPLUS_INCLUDE_PATH)
        # message_format (STATUS "${lead_mark_location}" "compiler option" "C_INCLUDE_PATH" "=" "${C_INCLUDE_PATH}")
        # message_format (STATUS "${lead_mark_location}" "compiler option" "CPLUS_INCLUDE_PATH" "=" "${CPLUS_INCLUDE_PATH}")
        # message_format (STATUS "${lead_mark_location}" "compiler option" "LIBRARY_PATH" "=" "${LIBRARY_PATH}")   # /usr/lib

        foreach(llvm_flag ${LLVM_DEFINITIONS})
            message_format (STATUS "${lead_mark_location}" "compiler option" "LLVM_DEFINITIONS" "=" "${llvm_flag}")
            # -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS
        endforeach()
        foreach(clang_flag ${CLANG_DEFINITIONS})
            message_format (STATUS "${lead_mark_location}" "compiler option" "CLANG_DEFINITIONS" "=" "${clang_flag}")
        endforeach()
        foreach(clang_dir ${LLVM_LIBRARY_DIRS})
            message_format (STATUS "${lead_mark_location}" "compiler option" "LLVM_LIBRARY_DIRS" "=" "${clang_dir}")
        endforeach()



        message_format (STATUS "${lead_mark_location}" "compiler option" "DEFAULT_INSTALL_PREFIX" "=" "${DEFAULT_INSTALL_PREFIX}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "LIBCXX_INSTALL_PREFIX" "=" "${LIBCXX_INSTALL_PREFIX}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "LLVM_INSTALL_PREFIX" "=" "${LLVM_INSTALL_PREFIX}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CLANG_INSTALL_PREFIX" "=" "${CLANG_INSTALL_PREFIX}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "LIBCXX_CXX_ABI_INCLUDE_PATHS" "=" "${LIBCXX_CXX_ABI_INCLUDE_PATHS5}")

        message_format (STATUS "${lead_mark_location}" "compiler option" "LLVM_INCLUDE_TESTS" "=" "${LLVM_INCLUDE_TESTS}")
        # Basic options ---------------------------------------------------------------
        option(LIBCXX_ENABLE_ASSERTIONS "Enable assertions independent of build mode." OFF)
        option(LIBCXX_ENABLE_SHARED "Build libc++ as a shared library." ON)
        option(LIBCXX_ENABLE_STATIC "Build libc++ as a static library." ON)
        option(LIBCXX_ENABLE_EXPERIMENTAL_LIBRARY "Build libc++experimental.a" ON)


        # https://git.mittelab.org/5p4k/rpi-build-tools/commit/be524f5f5d910e06749e1c65c089d470ef8e3d34
        string (PREPEND CMAKE_CXX_FLAGS_INIT "-stdlib=libc++ ")
        add_compile_options (${CMAKE_CXX_FLAGS_INIT})    # add_compile_definitions(${CMAKE_CXX_FLAGS_INIT}) won't work

        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_SHARED_LINKER_FLAGS_INIT" "=" "${CMAKE_SHARED_LINKER_FLAGS_INIT}")
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_STATIC_LINKER_FLAGS_INIT" "=" "${CMAKE_STATIC_LINKER_FLAGS_INIT}")
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_MODULE_LINKER_FLAGS_INIT" "=" "${CMAKE_MODULE_LINKER_FLAGS_INIT}")
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_EXE_LINKER_FLAGS_INIT" "=" "${CMAKE_EXE_LINKER_FLAGS_INIT}")
        set (CMAKE_SHARED_LINKER_FLAGS_INIT     "-fuse-ld=lld ${CMAKE_SHARED_LINKER_FLAGS_INIT}")
        set (CMAKE_STATIC_LINKER_FLAGS_INIT     "-fuse-ld=lld ${CMAKE_STATIC_LINKER_FLAGS_INIT}")
        set (CMAKE_MODULE_LINKER_FLAGS_INIT     "-fuse-ld=lld ${CMAKE_MODULE_LINKER_FLAGS_INIT}")
        set (CMAKE_EXE_LINKER_FLAGS_INIT        "-fuse-ld=lld ${CMAKE_EXE_LINKER_FLAGS_INIT}")
        set (CMAKE_C_FLAGS                      "-fuse-ld=lld ${CMAKE_C_FLAGS}")
        set (CMAKE_CXX_FLAGS                    "-fuse-ld=lld ${CMAKE_CXX_FLAGS}")
        # http://llvm.1065342.n5.nabble.com/llvm-dev-Compiling-for-baremetal-ARMv4-on-Ubuntu-Linux-td124226.html
        add_definitions(-DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY)
        set (CMAKE_TRY_COMPILE_TARGET_TYPE      "STATIC_LIBRARY")

        if (BUILD_SHARED_LIBS)
            # set (CMAKE_FIND_LIBRARY_SUFFIXES    ${CMAKE_SHARED_LIBRARY_SUFFIX} ${CMAKE_FIND_LIBRARY_SUFFIXES})
            set (CMAKE_FIND_LIBRARY_SUFFIXES    ${CMAKE_SHARED_LIBRARY_SUFFIX})
            set (CMAKE_EXE_LINKER_FLAGS     "${CMAKE_EXE_LINKER_FLAGS} -shared")
            add_link_options(-shared)   # for hunpell*.so
        else ()
            # set (CMAKE_FIND_LIBRARY_SUFFIXES    ${CMAKE_STATIC_LIBRARY_SUFFIX} ${CMAKE_FIND_LIBRARY_SUFFIXES})
            set (CMAKE_FIND_LIBRARY_SUFFIXES    ${CMAKE_STATIC_LIBRARY_SUFFIX})
            set (CMAKE_EXE_LINKER_FLAGS     "${CMAKE_EXE_LINKER_FLAGS} -static")
            add_link_options(-static)   # for hunpell*.a
        endif ()

        if (UNIX)
            if (BUILD_SHARED_LIBS)  # STATIC_LIBRARY, MODULE_LIBRARY, SHARED_LIBRARY, EXECUTABLE
                if (CMAKE_CXX_COMPILER_ID MATCHES "GNU") # STATIC_LIBRARY, MODULE_LIBRARY, SHARED_LIBRARY, EXECUTABLE
                    set (CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--no-undefined")
                    add_link_options("-Wl,--no-undefined")
                elseif (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
                    set (CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--no-undefined-error")
                    add_link_options("-Wl,--no-undefined-error")
                endif ()
            endif ()
        elseif (APPLE)
            if (BUILD_SHARED_LIBS)  # STATIC_LIBRARY, MODULE_LIBRARY, SHARED_LIBRARY, EXECUTABLE
                set (CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--no-undefined-error")
                add_link_options("-Wl,--no-undefined-error")
            endif ()
        endif ()

        set (CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--no-allow-shlib-undefined")
        add_link_options("-Wl,--no-allow-shlib-undefined")

        # if (NOT BUILD_SHARED_LIBS)  # STATIC_LIBRARY, MODULE_LIBRARY, SHARED_LIBRARY, EXECUTABLE
        # # set (CMAKE_STATIC_LINKER_FLAGS "${CMAKE_STATIC_LINKER_FLAGS} -Wl,--verbose")
        # set (CMAKE_STATIC_LINKER_FLAGS "${CMAKE_STATIC_LINKER_FLAGS} -ar")
        # # add_link_options("-Wl,--verbose")
        # add_link_options("-ar")
        # endif ()

        set (CMAKE_SHARED_LINK_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -rdynamic")                  # set (CMAKE_SHARED_LIBRARY_LINK_FLAGS "-rdynamic")
        set (CMAKE_SHARED_RUNTIME_FLAG "${CMAKE_SHARED_RUNTIME_FLAG} -Wl,-rpath,")              # set (CMAKE_SHARED_LIBRARY_RUNTIME_FLAG "-Wl,-rpath,")
        set (CMAKE_SHARED_RUNTIME_FLAG_SEP "${CMAKE_SHARED_RUNTIME_FLAG_SEP} :")                # set (CMAKE_SHARED_LIBRARY_RUNTIME_FLAG_SEP ":")
        set (CMAKE_SHARED_SONAME_FLAGS "${CMAKE_SHARED_SONAME_FLAGS} -rdynamic -Wl,-soname,")   # set (CMAKE_SHARED_LIBRARY_SONAME_FLAGS "-rdynamic -Wl,-soname,")

        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_SHARED_LINKER_FLAGS_INIT" "=" "${CMAKE_SHARED_LINKER_FLAGS_INIT}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_STATIC_LINKER_FLAGS_INIT" "=" "${CMAKE_STATIC_LINKER_FLAGS_INIT}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_MODULE_LINKER_FLAGS_INIT" "=" "${CMAKE_MODULE_LINKER_FLAGS_INIT}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_EXE_LINKER_FLAGS_INIT" "=" "${CMAKE_EXE_LINKER_FLAGS_INIT}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_SHARED_LINKER_FLAGS" "=" "${CMAKE_SHARED_LINKER_FLAGS}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_SHARED_RUNTIME_FLAG" "=" "${CMAKE_SHARED_RUNTIME_FLAG}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_SHARED_RUNTIME_FLAG_SEP" "=" "${CMAKE_SHARED_RUNTIME_FLAG_SEP}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_SHARED_SONAME_FLAGS" "=" "${CMAKE_SHARED_SONAME_FLAGS}")

        # https://gitlab.kitware.com/cmake/cmake/-/issues/18275

        # https://askubuntu.com/questions/898057/16-04-clang-bad-selection-of-gcc-toolchain
        # find /usr/include/c++/ -name cstdint
        # clang++ -v
        # clang -ccc-print-bindings main.cpp

        set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -v")    # set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -stdlib=libc++ -v")
        # set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -nostdinc++")
        # add_compile_options (-nostdinc++)
        set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++ -v")
        add_compile_options ("-stdlib=libc++" "-v")        # add_definitions(-stdlib=libc++)    # add_definitions(-v)
        # set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-exceptions")
        # add_compile_options ("-fno-exceptions")        # add_definitions(-stdlib=libc++)    # add_definitions(-v)
        # add_definitions(${CMAKE_C_FLAGS})           # add_compile_definitions(${CMAKE_C_FLAGS}) won't work
        # add_definitions(${CMAKE_CXX_FLAGS})         # add_compile_definitions(${CMAKE_CXX_FLAGS})    # -D "-stdlib=libc++ -v"    # won't work


        # https://reviews.llvm.org/D49502
        string (PREPEND CMAKE_CXX_STANDARD_LIBRARIES "-lc++abi -lc++ -lpthread -lunwind ") # -static
        add_definitions(${CMAKE_CXX_STANDARD_LIBRARIES})

        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_EXE_LINKER_FLAGS" "=" "${CMAKE_EXE_LINKER_FLAGS}")
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_STATIC_LINKER_FLAGS" "=" "${CMAKE_STATIC_LINKER_FLAGS}")

        # https://gist.github.com/RCL/6e2491729977dc9ba55967edc988b0bc
        # set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libc++ -lc++abi -nodefaultlibs -lc++experimental -lc++ -lc++abi -L${LLVM_LIBRARY_DIRS} -lpthread")  # -lm -lc -lgcc_s -lgcc
        # set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Os -rdynamic -stdlib=libc++ -lc++abi -lc++ -lc++experimental -lm -lc -lgcc_s -lgcc -lrt -lz  -L${LLVM_LIBRARY_DIRS} -lpthread")  # -lm -lc -lgcc_s -lgcc


        # set (CMAKE_EXE_LINKER_FLAGS     "${CMAKE_EXE_LINKER_FLAGS} -lm -lc -lgcc_s -lgcc")
        set (CMAKE_EXE_LINKER_FLAGS     "${CMAKE_EXE_LINKER_FLAGS} -lm -lc")
        # add_link_options("-lm" "-lc" "-lgcc_s" "-lgcc")
        add_link_options("-lm" "-lc")

        # set (CMAKE_EXE_LINKER_FLAGS     "-stdlib=libc++")
        # add_link_options("-stdlib=libc++")
        # [How to tell cmake to link libcxx correctly?](https://gitlab.kitware.com/cmake/cmake/-/issues/18275)
        set (CMAKE_EXE_LINKER_FLAGS     "${CMAKE_EXE_LINKER_FLAGS} -lc++abi -lc++")
        add_link_options("-lc++abi" "-lc++")
        set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -nostdlib")
        add_compile_options ("-nostdlib")
        set (CMAKE_EXE_LINKER_FLAGS     "${CMAKE_EXE_LINKER_FLAGS} -nostartfiles")
        add_link_options("-nostartfiles")
        set (CMAKE_EXE_LINKER_FLAGS     "${CMAKE_EXE_LINKER_FLAGS} -nodefaultlibs")
        add_link_options("-nodefaultlibs")
        # http://tolik1967.azurewebsites.net/clang_no_gcc.html
        set (CMAKE_EXE_LINKER_FLAGS     "${CMAKE_EXE_LINKER_FLAGS} -lrt -ldl -lz")
        add_link_options("-lrt" "-ldl" "-lz")
        # https://stackoverflow.com/questions/11116399/crt1-o-in-function-start-undefined-reference-to-main-in-linux
        set (CMAKE_EXE_LINKER_FLAGS     "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libc++ -rdynamic -lc++experimental -lpthread -lunwind -v")
        add_link_options("-stdlib=libc++" "-rdynamic" "-lc++experimental" "-lpthread" "-lunwind" "-v")
        # set (CMAKE_EXE_LINKER_FLAGS     "${CMAKE_EXE_LINKER_FLAGS} -O2")
        # add_link_options("-O2")
        # https://stackoverflow.com/questions/33822927/using-an-alternative-libc-in-a-cmake-project
        # set (CMAKE_EXE_LINKER_FLAGS     "${CMAKE_EXE_LINKER_FLAGS} -static -Os")  # -static will link components statically
        # add_link_options("-static" "-Os")
        set (CMAKE_EXE_LINKER_FLAGS     "${CMAKE_EXE_LINKER_FLAGS} -Os")  #
        add_link_options("-Os")
        # set (CMAKE_STATIC_LINKER_FLAGS  "-O2 -stdlib=libc++ -rdynamic -lc++abi -lunwind -lc++ -lpthread -lc -L${LLVM_LIBRARY_DIRS}")  # -lm -lc -lgcc_s -lgcc
        list (REMOVE_DUPLICATES DEPENDENCIES_LIBRARY_DIRS)
        foreach(flag ${${DEPENDENCIES_LIBRARY_DIRS}})
            message_format (STATUS "${lead_mark_location}" "compiler option" "DEPENDENCIES_LIBRARY_DIRS" "="  "${flag}")
            set (CMAKE_EXE_LINKER_FLAGS     "${CMAKE_EXE_LINKER_FLAGS} -L${flag}")  #
            add_link_options("-L${flag}")
        endforeach()

        # add_definitions(${CMAKE_EXE_LINKER_FLAGS})

        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES" "=" "${CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES}")
        # /usr/lib64/gcc/x86_64-linux-musl/9.3;/usr/lib64;/lib64;/usr/lib;/lib
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_CXX_IMPLICIT_LINK_LIBRARIES" "=" "${CMAKE_CXX_IMPLICIT_LINK_LIBRARIES}")
        # stdc++;m;gcc_s;gcc;c;gcc_s;gcc
        set(CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES "")
        set(CMAKE_CXX_IMPLICIT_LINK_LIBRARIES "")


        list (APPEND ${DEPENDENCIES_INCLUDE_DIRS} "${LLVM_INCLUDE_DIRS}")
        list (APPEND ${DEPENDENCIES_INCLUDE_DIRS} "${CLANG_INCLUDE_DIRS}")
        list (APPEND ${DEPENDENCIES_INCLUDE_DIRS} "${LLVM_INSTALL_PREFIX}/include/c++/v1")
        list (APPEND ${DEPENDENCIES_LIBRARY_DIRS} "${LLVM_LIBRARY_DIRS}")
        # target_include_directories (${PROJECT_NAME} INTERFACE PUBLIC ${LLVM_INCLUDE_DIRS})
        # target_include_directories (${PROJECT_NAME} INTERFACE PUBLIC ${CLANG_INCLUDE_DIRS})
        # target_link_directories (${PROJECT_NAME} PUBLIC ${LLVM_LIBRARY_DIRS})

        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_LINKER" "=" "${CMAKE_LINKER}") # /usr/bin/ld
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CLANG_DEFAULT_LINKER" "=" "${CLANG_DEFAULT_LINKER}")
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_LINK_EXECUTABLE" "=" "${CMAKE_LINK_EXECUTABLE}")

        set (CMAKE_LINKER                   "${CLANG_INSTALL_PREFIX}/bin/ld.lld" CACHE INTERNAL "" FORCE)    # set (CMAKE_LINKER        lld)
        # set (CLANG_DEFAULT_LINKER           "${CLANG_INSTALL_PREFIX}/bin/ld.lld")    # ld.lld->lld
        # set (CMAKE_LINK_EXECUTABLE          "${CLANG_INSTALL_PREFIX}/bin/ld.lld")

        set (CMAKE_LINKER                   "${CLANG_INSTALL_PREFIX}/bin/clang++")       # set (CMAKE_LINKER        "/usr/bin/llvm-ld")
        set (CLANG_DEFAULT_LINKER           "${CLANG_INSTALL_PREFIX}/bin/clang++")
        set (CMAKE_LINK_EXECUTABLE          "${CLANG_INSTALL_PREFIX}/bin/clang++")



        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_C_LINKER_FLAGS" "=" "${CMAKE_C_LINKER_FLAGS}")
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_CXX_LINKER_FLAGS" "=" "${CMAKE_CXX_LINKER_FLAGS}")
        if (("${CMAKE_BUILD_TYPE}" STREQUAL "Debug") OR ("${CMAKE_BUILD_TYPE}" STREQUAL ""))
            # set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}")
            set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}")
        endif ()
        set (CMAKE_C_LINKER_FLAGS ${CMAKE_EXE_LINKER_FLAGS})
        set (CMAKE_CXX_LINKER_FLAGS ${CMAKE_EXE_LINKER_FLAGS})
        # add_definitions(${CMAKE_CXX_LINKER_FLAGS})

        # set (CMAKE_C_LINK_EXECUTABLE "${CMAKE_C_COMPILER} ${CMAKE_C_FLAGS} ${CMAKE_CXX_LINKER_FLAGS} <FLAGS> <LINK_FLAGS> ${PLATFORM_CONFIG_L_FLAGS} <OBJECTS> -o <TARGET> <LINK_LIBRARIES> ${CMD_SRCS} ${LIB} ${DEPENDENCIES_LIBRARIES_STRING}" CACHE STRING "c linker executable" FORCE)
        # set (CMAKE_CXX_LINK_EXECUTABLE "<CMAKE_LINKER> ${CMAKE_C_FLAGS} -z --map_file=<TARGET_NAME>.map --output_file=<TARGET_NAME> ${PLATFORM_CONFIG_L_FLAGS} <OBJECTS> ${CMD_SRCS} ${LIB}" CACHE STRING "linker executable")
        # set (CMAKE_CXX_LINK_EXECUTABLE "${CMAKE_LINKER} ${CMAKE_C_FLAGS} ${CMAKE_CXX_LINKER_FLAGS} ${CMAKE_CXX_LINKER_FLAGS} -z --map_file=${PROJECT_NAME}.map --output_file=${PROJECT_NAME} ${PLATFORM_CONFIG_L_FLAGS} <OBJECTS> ${CMD_SRCS} ${LIB}" CACHE STRING "linker executable" FORCE)
        # clang-11: error: unsupported option '--output_file=tute'
        # set (CMAKE_CXX_LINK_EXECUTABLE "${CMAKE_LINKER} ${CMAKE_C_FLAGS} ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_LINKER_FLAGS} <FLAGS> <LINK_FLAGS> ${PLATFORM_CONFIG_L_FLAGS} <OBJECTS> -o <TARGET> <LINK_LIBRARIES> ${CMD_SRCS} ${LIB}" CACHE STRING "linker executable" FORCE)



        # set (CMAKE_C_LINK_EXECUTABLE         "${CMAKE_C_COMPILER}   ${CMAKE_C_FLAGS}   ${CMAKE_CXX_LINKER_FLAGS} <FLAGS> <LINK_FLAGS> ${PLATFORM_CONFIG_L_FLAGS} <OBJECTS> -o <TARGET> <LINK_LIBRARIES> ${CMD_SRCS} ${LIB} ${DEPENDENCIES_LIBRARIES_STRING}" CACHE STRING "c linker executable" FORCE)
        # set (CMAKE_CXX_LINK_EXECUTABLE       "${CMAKE_CXX_COMPILER} ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_LINKER_FLAGS} <FLAGS> <LINK_FLAGS> ${PLATFORM_CONFIG_L_FLAGS} <OBJECTS> -o <TARGET> <LINK_LIBRARIES> ${CMD_SRCS} ${LIB} ${DEPENDENCIES_LIBRARIES_STRING}" CACHE STRING "cxx linker executable" FORCE)
        # set (CMAKE_C_CREATE_SHARED_LIBRARY   "${CMAKE_C_COMPILER}   ${CMAKE_C_FLAGS}   ${CMAKE_CXX_LINKER_FLAGS} <FLAGS> <LINK_FLAGS> ${PLATFORM_CONFIG_L_FLAGS} <OBJECTS> -o <TARGET> <LINK_LIBRARIES> ${CMD_SRCS} ${LIB} ${DEPENDENCIES_LIBRARIES_STRING}" CACHE STRING "c create shared library" FORCE)
        # set (CMAKE_CXX_CREATE_SHARED_LIBRARY "${CMAKE_CXX_COMPILER} ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_LINKER_FLAGS} <FLAGS> <LINK_FLAGS> ${PLATFORM_CONFIG_L_FLAGS} <OBJECTS> -o <TARGET> <LINK_LIBRARIES> ${CMD_SRCS} ${LIB} ${DEPENDENCIES_LIBRARIES_STRING}" CACHE STRING "cxx create shared library" FORCE)

        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_C_LINK_EXECUTABLE" "=" "${CMAKE_C_LINK_EXECUTABLE}")      #
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_CXX_LINK_EXECUTABLE" "=" "${CMAKE_CXX_LINK_EXECUTABLE}")  #
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_C_CREATE_SHARED_LIBRARY" "=" "${CMAKE_C_CREATE_SHARED_LIBRARY}")        #
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_CXX_CREATE_SHARED_LIBRARY" "=" "${CMAKE_CXX_CREATE_SHARED_LIBRARY}")    #
        # set (CMAKE_C_LINK_EXECUTABLE         "${CMAKE_C_COMPILER}   ${CMAKE_C_FLAGS}   ${CMAKE_CXX_FLAGS} ${CMAKE_EXE_LINKER_FLAGS} <LINK_FLAGS> ${PLATFORM_CONFIG_L_FLAGS} <OBJECTS> -o <TARGET> <LINK_LIBRARIES> ${CMD_SRCS} ${LIB} ${DEPENDENCIES_LIBRARIES_FLAGS}" CACHE STRING "c linker executable" FORCE)
        # set (CMAKE_CXX_LINK_EXECUTABLE       "${CMAKE_CXX_COMPILER} ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS} ${CMAKE_EXE_LINKER_FLAGS} <LINK_FLAGS> ${PLATFORM_CONFIG_L_FLAGS} <OBJECTS> -o <TARGET> <LINK_LIBRARIES> ${CMD_SRCS} ${LIB} ${DEPENDENCIES_LIBRARIES_FLAGS}" CACHE STRING "cxx linker executable" FORCE)
        # set (CMAKE_C_CREATE_SHARED_LIBRARY   "${CMAKE_C_COMPILER}   ${CMAKE_C_FLAGS}   ${CMAKE_CXX_FLAGS} ${CMAKE_C_LINKER_FLAGS}   <LINK_FLAGS> ${PLATFORM_CONFIG_L_FLAGS} <OBJECTS> -o <TARGET> <LINK_LIBRARIES> ${CMD_SRCS} ${LIB} ${DEPENDENCIES_LIBRARIES_FLAGS}" CACHE STRING "c create shared library" FORCE)
        # set (CMAKE_CXX_CREATE_SHARED_LIBRARY "${CMAKE_CXX_COMPILER} ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_LINKER_FLAGS} <LINK_FLAGS> ${PLATFORM_CONFIG_L_FLAGS} <OBJECTS> -o <TARGET> <LINK_LIBRARIES> ${CMD_SRCS} ${LIB} ${DEPENDENCIES_LIBRARIES_FLAGS}" CACHE STRING "cxx create shared library" FORCE)

        set (CMAKE_C_LINK_EXECUTABLE         "${CMAKE_C_COMPILER}   ${CMAKE_C_FLAGS}   ${CMAKE_CXX_FLAGS} ${CMAKE_EXE_LINKER_FLAGS} <LINK_FLAGS> ${PLATFORM_CONFIG_L_FLAGS} <OBJECTS> -o <TARGET> <LINK_LIBRARIES> ${CMD_SRCS} ${LIB} " CACHE STRING "c linker executable" FORCE)
        set (CMAKE_CXX_LINK_EXECUTABLE       "${CMAKE_CXX_COMPILER} ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS} ${CMAKE_EXE_LINKER_FLAGS} <LINK_FLAGS> ${PLATFORM_CONFIG_L_FLAGS} <OBJECTS> -o <TARGET> <LINK_LIBRARIES> ${CMD_SRCS} ${LIB} " CACHE STRING "cxx linker executable" FORCE)
        set (CMAKE_C_CREATE_SHARED_LIBRARY   "${CMAKE_C_COMPILER}   ${CMAKE_C_FLAGS}   ${CMAKE_CXX_FLAGS} ${CMAKE_C_LINKER_FLAGS}   <LINK_FLAGS> ${PLATFORM_CONFIG_L_FLAGS} <OBJECTS> -o <TARGET> <LINK_LIBRARIES> ${CMD_SRCS} ${LIB} " CACHE STRING "c create shared library" FORCE)
        set (CMAKE_CXX_CREATE_SHARED_LIBRARY "${CMAKE_CXX_COMPILER} ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_LINKER_FLAGS} <LINK_FLAGS> ${PLATFORM_CONFIG_L_FLAGS} <OBJECTS> -o <TARGET> <LINK_LIBRARIES> ${CMD_SRCS} ${LIB} " CACHE STRING "cxx create shared library" FORCE)

        # CMakeCXXInformation.cmake
        # Create a static archive incrementally for large object file counts.
        # If CMAKE_CXX_CREATE_STATIC_LIBRARY is set it will override these.
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_C_ARCHIVE_CREATE" "=" "${CMAKE_C_ARCHIVE_CREATE}")      # <CMAKE_AR> qc <TARGET> <LINK_FLAGS> <OBJECTS>
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_CXX_ARCHIVE_CREATE" "=" "${CMAKE_CXX_ARCHIVE_CREATE}")  # <CMAKE_AR> qc <TARGET> <LINK_FLAGS> <OBJECTS>
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_CXX_ARCHIVE_APPEND" "=" "${CMAKE_CXX_ARCHIVE_APPEND}")  # <CMAKE_AR> q  <TARGET> <LINK_FLAGS> <OBJECTS>
        message_format (STATUS "${lead_mark_location}" "compiler option initial" "CMAKE_CXX_ARCHIVE_FINISH" "=" "${CMAKE_CXX_ARCHIVE_FINISH}")  # <CMAKE_RANLIB> <TARGET>
        # # set (CMAKE_C_ARCHIVE_CREATE "<CMAKE_AR> --create -o <TARGET> <LINK_FLAGS> <OBJECTS>")
        # set (CMAKE_C_ARCHIVE_CREATE     "<CMAKE_AR> qc <TARGET> <LINK_FLAGS> <OBJECTS>")
        # # set (CMAKE_CXX_ARCHIVE_CREATE "<CMAKE_AR> --create -o <TARGET> <LINK_FLAGS> <OBJECTS>")
        # set (CMAKE_CXX_ARCHIVE_CREATE   "<CMAKE_AR> qc <TARGET> <LINK_FLAGS> <OBJECTS>")
        # # https://stackoverflow.com/questions/5659225/how-do-i-set-the-options-for-cmake-ar
        # # set (CMAKE_C_ARCHIVE_CREATE "<CMAKE_AR> -X -r5 -o <TARGET> <LINK_FLAGS> <OBJECTS>")
        # # # set (CMAKE_C_CREATE_STATIC_LIBRARY "<CMAKE_AR> cr <TARGET> <LINK_FLAGS> <OBJECTS> ;<CMAKE_RANLIB> -c <TARGET> ")
        # # set (CMAKE_C_CREATE_STATIC_LIBRARY "<CMAKE_AR> <TARGET> --create <LINK_FLAGS> <OBJECTS> ;<CMAKE_RANLIB> -c <TARGET> ")
        # # set (CMAKE_CXX_ARCHIVE_CREATE "<CMAKE_AR> -X -r5 -o <TARGET> <LINK_FLAGS> <OBJECTS>")
        # # # set (CMAKE_CXX_CREATE_STATIC_LIBRARY "<CMAKE_AR> cr <TARGET> <LINK_FLAGS> <OBJECTS> ;<CMAKE_RANLIB> -c <TARGET> ")
        # # set (CMAKE_CXX_CREATE_STATIC_LIBRARY "<CMAKE_AR> <TARGET> --create <LINK_FLAGS> <OBJECTS> ;<CMAKE_RANLIB> -c <TARGET> ")

        # # https://fuchsia.googlesource.com/third_party/cmake/+/v3.5.1/Modules/Compiler/SunPro-CXX.cmake
        # # set (CMAKE_CXX_CREATE_STATIC_LIBRARY
        # #  "<CMAKE_CXX_COMPILER> -xar -o <TARGET> <OBJECTS> "
        # #  "<CMAKE_RANLIB> <TARGET> ")

        # # https://www.dynamsoft.com/codepool/webassembly-standalone-dynamic-linking-wasm.html
        # set (CMAKE_C_CREATE_STATIC_LIBRARY
        #  "<CMAKE_C_COMPILER> -o <TARGET> <LINK_FLAGS> <OBJECTS> "
        #  "<CMAKE_RANLIB> -c <TARGET> ")
        # set (CMAKE_CXX_CREATE_STATIC_LIBRARY
        #  "<CMAKE_CXX_COMPILER> -o <TARGET> <LINK_FLAGS> <OBJECTS> "
        #  "<CMAKE_RANLIB> -c <TARGET> ")


        # # set (CMAKE_C_CREATE_STATIC_LIBRARY   "${CMAKE_C_COMPILER}   ${CMAKE_C_FLAGS}   ${CMAKE_STATIC_LINKER_FLAGS} <LINK_FLAGS> ${PLATFORM_CONFIG_L_FLAGS} <OBJECTS> -o <TARGET> <LINK_LIBRARIES> ${CMD_SRCS} ${LIB} ${DEPENDENCIES_LIBRARIES_STRING}" CACHE STRING "c create static library" FORCE)
        # set (CMAKE_C_CREATE_STATIC_LIBRARY   "${CMAKE_C_COMPILER}   ${CMAKE_C_FLAGS}   ${CMAKE_CXX_FLAGS} ${CMAKE_C_LINKER_FLAGS}   <LINK_FLAGS> ${PLATFORM_CONFIG_L_FLAGS} <OBJECTS> -o <TARGET> <LINK_LIBRARIES> ${CMD_SRCS} ${LIB} ${DEPENDENCIES_LIBRARIES_STRING}; <CMAKE_RANLIB> <TARGET> " CACHE STRING "c create static library" FORCE)
        # set(CMAKE_C_CREATE_STATIC_LIBRARY   "<CMAKE_AR> -ar qc <TARGET> <LINK_FLAGS> <OBJECTS>"
        #                                 "<CMAKE_RANLIB> <TARGET> ")

        # # set (CMAKE_CXX_CREATE_STATIC_LIBRARY "${CMAKE_CXX_COMPILER} ${CMAKE_CXX_FLAGS} ${CMAKE_STATIC_LINKER_FLAGS} <LINK_FLAGS> ${PLATFORM_CONFIG_L_FLAGS} <OBJECTS> -o <TARGET> <LINK_LIBRARIES> ${CMD_SRCS} ${LIB} ${DEPENDENCIES_LIBRARIES_STRING}" CACHE STRING "cxx create static library" FORCE)
        # set (CMAKE_CXX_CREATE_STATIC_LIBRARY "${CMAKE_CXX_COMPILER} ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_LINKER_FLAGS} <LINK_FLAGS> ${PLATFORM_CONFIG_L_FLAGS} <OBJECTS> -o <TARGET> <LINK_LIBRARIES> ${CMD_SRCS} ${LIB} ${DEPENDENCIES_LIBRARIES_STRING}; <CMAKE_RANLIB> <TARGET> " CACHE STRING "cxx create static library" FORCE)
        # set(CMAKE_CXX_CREATE_STATIC_LIBRARY "<CMAKE_AR> -ar qc <TARGET> <LINK_FLAGS> <OBJECTS>"
        #                                 "<CMAKE_RANLIB> <TARGET> ")

        # https://github.com/ros/rosdistro/issues/13333
        add_definitions (-D"CMAKE_FIND_FRAMEWORK=LAST")

        # set (LLVM_ENABLE_PROJECTS "clang;libcxx;libcxxabi")
        # add_definitions(${LLVM_ENABLE_PROJECTS})

        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_C_FLAGS" "=" "${CMAKE_C_FLAGS}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_CXX_FLAGS" "=" "${CMAKE_CXX_FLAGS}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_CXX_COMPILER_FLAGS" "=" "${CMAKE_CXX_COMPILER_FLAGS}")
        # foreach(link_flag ${CMAKE_EXE_LINKER_FLAGS})
            # message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_EXE_LINKER_FLAGS" "=" "${link_flag}")
            message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_EXE_LINKER_FLAGS" "=" "${CMAKE_EXE_LINKER_FLAGS}")
        # endforeach()
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_STATIC_LINKER_FLAGS" "=" "${CMAKE_STATIC_LINKER_FLAGS}")

        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_CXX_LINKER_FLAGS" "=" "${CMAKE_CXX_LINKER_FLAGS}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_LINKER" "=" "${CMAKE_LINKER}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CLANG_DEFAULT_LINKER" "=" "${CLANG_DEFAULT_LINKER}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_LINK_EXECUTABLE" "=" "${CMAKE_LINK_EXECUTABLE}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "PLATFORM_CONFIG_L_FLAGS" "=" "${PLATFORM_CONFIG_L_FLAGS}")

        message_format (STATUS "${lead_mark_location}" "compiler option" "FLAGS" "=" "${FLAGS}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "LINK_FLAGS" "=" "${LINK_FLAGS}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "OBJECTS" "=" "${OBJECTS}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "TARGET" "=" "${TARGET}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "TARGET_NAME" "=" "${TARGET_NAME}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "LINK_LIBRARIES" "=" "${LINK_LIBRARIES}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "REQ_LLVM_LIBRARIES" "=" "${REQ_LLVM_LIBRARIES}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMD_SRCS" "=" "${CMD_SRCS}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "LIB" "=" "${LIB}")
        # if (NOT DEFINED lead_mark_location)
        # set (lead_mark_location 57 CACHE STRING "location of lead mark, eg. =" FORCE)
        # endif ()
        message_format (STATUS "${lead_mark_location}" "compiler option" "initial CMAKE_C_LINK_EXECUTABLE"          "=" "${CMAKE_C_LINK_EXECUTABLE}")    # <CMAKE_CXX_COMPILER> <FLAGS> <CMAKE_CXX_LINKER_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>
        message_format (STATUS "${lead_mark_location}" "compiler option" "initial CMAKE_CXX_LINK_EXECUTABLE"        "=" "${CMAKE_CXX_LINK_EXECUTABLE}")  # <CMAKE_CXX_COMPILER> <FLAGS> <CMAKE_CXX_LINKER_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>
        message_format (STATUS "${lead_mark_location}" "compiler option" "initial CMAKE_C_CREATE_SHARED_LIBRARY"    "=" "${CMAKE_C_CREATE_SHARED_LIBRARY}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "initial CMAKE_CXX_CREATE_SHARED_LIBRARY"  "=" "${CMAKE_CXX_CREATE_SHARED_LIBRARY}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_C_LINK_EXECUTABLE"                  "=" "${CMAKE_C_LINK_EXECUTABLE}")    # <CMAKE_CXX_COMPILER> <FLAGS> <CMAKE_CXX_LINKER_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_CXX_LINK_EXECUTABLE"                "=" "${CMAKE_CXX_LINK_EXECUTABLE}")  # <CMAKE_CXX_COMPILER> <FLAGS> <CMAKE_CXX_LINKER_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_C_CREATE_SHARED_LIBRARY"            "=" "${CMAKE_C_CREATE_SHARED_LIBRARY}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_CXX_CREATE_SHARED_LIBRARY"          "=" "${CMAKE_CXX_CREATE_SHARED_LIBRARY}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_C_CREATE_STATIC_LIBRARY"            "=" "${CMAKE_C_CREATE_STATIC_LIBRARY}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_CXX_CREATE_STATIC_LIBRARY"          "=" "${CMAKE_CXX_CREATE_STATIC_LIBRARY}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_CXX_COMPILE_OBJECT"                 "=" "${CMAKE_CXX_COMPILE_OBJECT}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_CXX_ARCHIVE_CREATE"                 "=" "${CMAKE_CXX_ARCHIVE_CREATE}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_C_ARCHIVE_CREATE"                   "=" "${CMAKE_C_ARCHIVE_CREATE}")
        # message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_CXX_STANDARD_LIBRARIES              " "=" "${CMAKE_CXX_STANDARD_LIBRARIES}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_CLANG_COMPILER_EXTERNAL_TOOLCHAIN" "=" "${CMAKE_CLANG_COMPILER_EXTERNAL_TOOLCHAIN}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "COMPILE_DEFINITIONS" "=" "${COMPILE_DEFINITIONS}")
        message_format (STATUS "${lead_mark_location}" "compiler option" "COMPILE_OPTIONS" "=" "${COMPILE_OPTIONS}")

        message_format (STATUS "${lead_mark_location}" "compiler option" "LLVM_ENABLE_PROJECTS" "=" "${LLVM_ENABLE_PROJECTS}")
        # message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_CURRENT_LIST_DIR" "=" "${CMAKE_CURRENT_LIST_DIR}")

        list (APPEND ${DEPENDENCIES_LIBRARIES} "${REQ_LLVM_LIBRARIES}")

        foreach(compiler_link_dependency ${${DEPENDENCIES_LIBRARIES}})
            message_format (STATUS "${lead_mark_location}" "compiler option" "DEPENDENCIES_LIBRARIES" "=" "${compiler_link_dependency}")
        endforeach()

        # cmake
        # -D CMAKE_C_COMPILER=clang
        # -D CMAKE_CXX_COMPILER=clang++
        # -D CMAKE_CXX_FLAGS=-stdlib=libc++
        # -D CMAKE_EXE_LINKER_FLAGS=-stdlib=libc++
        # -D CMAKE_BUILD_TYPE=Release
        # -H.
        # -B build/ClangRelease




        # list (APPEND ${DEPENDENCIES_INCLUDE_DIRS} "${LLVM_INCLUDE_DIRS}")
        # list (APPEND ${DEPENDENCIES_INCLUDE_DIRS} "${CLANG_INCLUDE_DIRS}")
        #>> list (APPEND ${DEPENDENCIES_INCLUDE_DIRS} "${LLVM_INSTALL_PREFIX}/include/c++/v1")

    else ()
        if (CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
            # using clang with clang-cl front end
        elseif (CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "GNU")
            # using clang with regular front end
        endif ()
    endif ()


    # string (FIND "${CMAKE_CXX_COMPILER}" "clang++" gplusplus_index)
    # if (NOT ${gplusplus_index} EQUAL -1 )
    #  list (APPEND ${DEPENDENCIES_INCLUDE_DIRS} ${LLVM_INCLUDE_DIRS})
    #  list (APPEND ${DEPENDENCIES_INCLUDE_DIRS} ${CLANG_INCLUDE_DIRS})
    #  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -nostdinc++ -nodefaultlibs -lc++ -lc++abi -lm -lc")    # -lgcc_s -lgcc
    #  message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_CXX_FLAGS        " "=" "${CMAKE_CXX_FLAGS}")
    #  # LLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi"
    # endif ()


endmacro()

# # Test begin without compiler_options_setting invocation_________________________________________________________
# find_package(Clang REQUIRED)
# if (Clang_FOUND)
#     message_format (STATUS "${lead_mark_location}" "compiler option" "Clang support included.")
#     message_format (STATUS "${lead_mark_location}" "compiler option" "CLANG_INSTALL_PREFIX" "=" "${CLANG_INSTALL_PREFIX}")
#     message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_C_COMPILER" "=" "${CMAKE_C_COMPILER}")
#     message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_CXX_COMPILER" "=" "${CMAKE_CXX_COMPILER}")
# endif ()
# if (NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
#
#
#     message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_C_COMPILER" "=" "${CMAKE_C_COMPILER}")
#     message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_CXX_COMPILER" "=" "${CMAKE_CXX_COMPILER}")
#     if (DEFINED CLANG_INSTALL_PREFIX)
#         set (CMAKE_C_COMPILER   "${CLANG_INSTALL_PREFIX}/bin/clang"    CACHE STRING "C compiler" FORCE)
#         set (CMAKE_CXX_COMPILER "${CLANG_INSTALL_PREFIX}/bin/clang++"  CACHE STRING "C++ compiler" FORCE)
#     endif ()
#
# endif ()
#
# set(CMAKE_CXX_EXTENSIONS OFF)   # gnu++
# # Find CMake file for Clang
# # find_package (Clang REQUIRED)
# find_package(LLVM REQUIRED CONFIG)
# enable_language(CXX)
# # message_format (STATUS "${lead_mark_location}" "compiler option" "Clang support included.")
# # Add path to LLVM modules
# list (APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")
#
# # import LLVM CMake functions
# include(AddLLVM)
#
# include_directories(${LLVM_INCLUDE_DIRS})
# include_directories(${CLANG_INCLUDE_DIRS})
#
# add_definitions(${LLVM_DEFINITIONS})
# add_definitions(${CLANG_DEFINITIONS})
# if (NOT DEFINED CLANG_INSTALL_PREFIX)
#     message_format (FATAL_ERROR "${lead_mark_location}" "compiler option" "CLANG_INSTALL_PREFIX NOT DEFINED" "" "")
# endif ()
#
# # https://stackoverflow.com/questions/43969219/error-libc-so-undefined-reference-to-unwind-getregionstart
# # https://stackoverflow.com/questions/7031126/switching-between-gcc-and-clang-llvm-using-cmake
# set (CMAKE_C_COMPILER               "${CLANG_INSTALL_PREFIX}/bin/clang")
# string (FIND "${CMAKE_C_FLAGS}" "-Wall -std=c99" initial_index)
# if (${initial_index} EQUAL -1)
#     set (CMAKE_C_FLAGS                  "${CMAKE_C_FLAGS} -Wall -std=c99")
# endif ()
#
# # set (CMAKE_C_FLAGS                  "${CMAKE_C_FLAGS} -flto")
# set (CMAKE_C_FLAGS_DEBUG            "-g")    # set (CMAKE_C_FLAGS_DEBUG            "${CMAKE_C_FLAGS_DEBUG} -g")
# set (CMAKE_C_FLAGS_MINSIZEREL       "-Os -DNDEBUG")    # set (CMAKE_C_FLAGS_MINSIZEREL       "${CMAKE_C_FLAGS_MINSIZEREL} -Os -DNDEBUG")
# set (CMAKE_C_FLAGS_RELEASE          "-O4 -DNDEBUG")    # set (CMAKE_C_FLAGS_RELEASE          "${CMAKE_C_FLAGS_RELEASE} -O4 -DNDEBUG")
# set (CMAKE_C_FLAGS_RELWITHDEBINFO   "-O2 -g")    # set (CMAKE_C_FLAGS_RELWITHDEBINFO   "${CMAKE_C_FLAGS_RELWITHDEBINFO} -O2 -g")
#
# set (CMAKE_CXX_COMPILER             "${CLANG_INSTALL_PREFIX}/bin/clang++")
# string (FIND "${CMAKE_CXX_FLAGS}" "-Wall" initial_index)
# if (${initial_index} EQUAL -1)
#     set (CMAKE_CXX_FLAGS                "${CMAKE_CXX_FLAGS} -Wall")
# endif ()
#
# # set (CMAKE_CXX_FLAGS                "${CMAKE_CXX_FLAGS} -flto")
# set (CMAKE_CXX_FLAGS_DEBUG          "-g")    # set (CMAKE_CXX_FLAGS_DEBUG          "${CMAKE_CXX_FLAGS_DEBUG} -g")
# set (CMAKE_CXX_FLAGS_MINSIZEREL     "-Os -DNDEBUG")    # set (CMAKE_CXX_FLAGS_MINSIZEREL     "${CMAKE_CXX_FLAGS_MINSIZEREL} -Os -DNDEBUG")
# set (CMAKE_CXX_FLAGS_RELEASE        "-O4 -DNDEBUG")    # set (CMAKE_CXX_FLAGS_RELEASE        "${CMAKE_CXX_FLAGS_RELEASE} -O4 -DNDEBUG")
# set (CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 -g")    # set (CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -O2 -g")
#
# set (CMAKE_AR                        "${CLANG_INSTALL_PREFIX}/bin/llvm-ar")
# set (CMAKE_AS                        "${CLANG_INSTALL_PREFIX}/bin/llvm-as")
# set (CMAKE_NM                        "${CLANG_INSTALL_PREFIX}/bin/llvm-nm")
# set (CLANG_DEFAULT_RTLIB             compiler-rt)
# set (CLANG_ENABLE_BOOTSTRAP          ON)
# set (LIBCXX_USE_COMPILER_RT          ON)
# set (LIBUNWIND_USE_COMPILER_RT       ON)
# set (LLVM_ENABLE_LLD                 ON)
# set (LLVM_ENABLE_LIBCXX              ON)
# set (LIBCXXABI_USE_LLVM_UNWINDER     ON)
# set (LIBCXXABI_USE_COMPILER_RT       ON)
# set (BOOTSTRAP_LLVM_ENABLE_LLD)
#
#
# message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_OBJDUMP" "=" "${CMAKE_OBJDUMP}")   # /usr/bin/objdump
# message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_RANLIB" "=" "${CMAKE_RANLIB}")     # /usr/bin/ranlib
# set (CMAKE_OBJDUMP "${CLANG_INSTALL_PREFIX}/bin/llvm-objdump")
# set (CMAKE_RANLIB  "${CLANG_INSTALL_PREFIX}/bin/llvm-ranlib")   # /usr/bin/llvm-ranlib -> llvm-ar
#
# option(LIBCXX_ENABLE_ASSERTIONS "Enable assertions independent of build mode." OFF)
# option(LIBCXX_ENABLE_SHARED "Build libc++ as a shared library." ON)
# option(LIBCXX_ENABLE_STATIC "Build libc++ as a static library." ON)
# option(LIBCXX_ENABLE_EXPERIMENTAL_LIBRARY "Build libc++experimental.a" ON)
# set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -v")    # set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -stdlib=libc++ -v")
# # set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++ -v")
# # set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -frtti -lc++experimental -lc++ -lc++abi -lm -lc -lgcc_s -lgcc")
# # set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -lc++experimental -lc++ -lc++abi -lm -lc -lgcc_s -lgcc")
# # set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -nostdinc++")
#>>        set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++ -v")
# add_definitions(${CMAKE_C_FLAGS})           # add_compile_definitions(${CMAKE_C_FLAGS}) won't work
# add_definitions(${CMAKE_CXX_FLAGS})         # add_compile_definitions(${CMAKE_CXX_FLAGS}) won't work
#
#
# message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_EXE_LINKER_FLAGS" "=" "${CMAKE_EXE_LINKER_FLAGS}")
# message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_STATIC_LINKER_FLAGS" "=" "${CMAKE_STATIC_LINKER_FLAGS}")
# # https://gist.github.com/RCL/6e2491729977dc9ba55967edc988b0bc
# # set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libc++ -lc++abi -nodefaultlibs -lc++experimental -lc++ -lc++abi -L${LLVM_LIBRARY_DIRS} -lpthread")  # -lm -lc -lgcc_s -lgcc
# # set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Os -rdynamic -stdlib=libc++ -lc++abi -lc++ -lc++experimental -lm -lc -lgcc_s -lgcc -lrt -lz  -L${LLVM_LIBRARY_DIRS} -lpthread")  # -lm -lc -lgcc_s -lgcc
# #>>   set (CMAKE_EXE_LINKER_FLAGS     "-O2 -stdlib=libc++ -rdynamic -lc++abi -lunwind -lc++ -lpthread -lc -L${LLVM_LIBRARY_DIRS}")  # -lm -lc -lgcc_s -lgcc
# #>>   set (CMAKE_STATIC_LINKER_FLAGS  "-O2 -stdlib=libc++ -rdynamic -lc++abi -lunwind -lc++ -lpthread -lc -L${LLVM_LIBRARY_DIRS}")  # -lm -lc -lgcc_s -lgcc
# # add_definitions(${CMAKE_EXE_LINKER_FLAGS})
#
# if (("${CMAKE_BUILD_TYPE}" STREQUAL "Debug") OR ("${CMAKE_BUILD_TYPE}" STREQUAL ""))
#     # set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}")
#     set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}")
# endif ()
# set (CMAKE_CXX_LINKER_FLAGS ${CMAKE_EXE_LINKER_FLAGS})
# # add_definitions(${CMAKE_CXX_LINKER_FLAGS})
#
# #>>   set (CMAKE_C_CREATE_STATIC_LIBRARY   "${CMAKE_C_COMPILER}   ${CMAKE_C_FLAGS}   ${CMAKE_STATIC_LINKER_FLAGS} <LINK_FLAGS> ${PLATFORM_CONFIG_L_FLAGS} <OBJECTS> -o <TARGET> <LINK_LIBRARIES> ${CMD_SRCS} ${LIB} ${DEPENDENCIES_LIBRARIES_STRING}" CACHE STRING "c create static library" FORCE)
# #>>   set (CMAKE_CXX_CREATE_STATIC_LIBRARY "${CMAKE_CXX_COMPILER} ${CMAKE_CXX_FLAGS} ${CMAKE_STATIC_LINKER_FLAGS} <LINK_FLAGS> ${PLATFORM_CONFIG_L_FLAGS} <OBJECTS> -o <TARGET> <LINK_LIBRARIES> ${CMD_SRCS} ${LIB} ${DEPENDENCIES_LIBRARIES_STRING}" CACHE STRING "cxx create static library" FORCE)
#
# # https://git.mittelab.org/5p4k/rpi-build-tools/commit/be524f5f5d910e06749e1c65c089d470ef8e3d34
# string (PREPEND CMAKE_CXX_FLAGS_INIT "-stdlib=libc++ ")
# add_definitions(${CMAKE_CXX_FLAGS_INIT})    # add_compile_definitions(${CMAKE_CXX_FLAGS_INIT}) won't work
# # https://reviews.llvm.org/D49502
# string (PREPEND CMAKE_CXX_STANDARD_LIBRARIES "-lc++abi -lunwind -lc++ -lpthread ") # -static
# add_definitions(${CMAKE_CXX_STANDARD_LIBRARIES})
#
# set(CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES "")
# set(CMAKE_CXX_IMPLICIT_LINK_LIBRARIES "")
# set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fuse-ld=lld")
# set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fuse-ld=lld")
# set (CMAKE_LINKER                    "${CLANG_INSTALL_PREFIX}/bin/clang++")       # set (CMAKE_LINKER        "/usr/bin/llvm-ld")
# set (CLANG_DEFAULT_LINKER            "${CLANG_INSTALL_PREFIX}/bin/clang++")
# set (CMAKE_LINK_EXECUTABLE           "${CLANG_INSTALL_PREFIX}/bin/clang++")
# message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_LINKER" "=" "${CMAKE_LINKER}") # /usr/bin/ld
# message_format (STATUS "${lead_mark_location}" "compiler option" "CLANG_DEFAULT_LINKER" "=" "${CLANG_DEFAULT_LINKER}")
# message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_LINK_EXECUTABLE" "=" "${CMAKE_LINK_EXECUTABLE}")
#
list (APPEND DEPENDENCIES_INCLUDE_DIRS "${LLVM_INCLUDE_DIRS}")
list (APPEND DEPENDENCIES_INCLUDE_DIRS "${CLANG_INCLUDE_DIRS}")
list (APPEND DEPENDENCIES_INCLUDE_DIRS "${LLVM_INSTALL_PREFIX}/include/c++/v1")
list (APPEND ${DEPENDENCIES_LIBRARY_DIRS} "${LLVM_LIBRARY_DIRS}")
# # Test end ______________________________________________________________________________________________________

# message_format (STATUS "${lead_mark_location}" "compiler option" "CMAKE_CURRENT_LIST_DIR" "=" "${CMAKE_CURRENT_LIST_DIR}")
include (${CMAKE_CURRENT_LIST_DIR}/system-information.cmake)
include (${CMAKE_ROOT}/Modules/CMakeCXXInformation.cmake)

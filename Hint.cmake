
if(UNIX AND NOT APPLE)
    # Linux
    set(HSDIS_HINT "You can make it avaialble to the linker (-> and JVM) with the following command:
    sudo cp ${FILE} /usr/lib/
 or:
    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${DIR}' >> ~/.bashrc")
elseif (UNIX)
    # OS X
    set(HSDIS_HINT "You can make it avaialble to the linker (-> and JVM) with the following command:
    echo 'export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:${DIR}>' >> ~/.zshrc")
else()
    set(HSDIS_HINT
            "I don't have a hint for your OS ¯\_(ツ)_/¯. Consider filing an issue?")
endif()

execute_process(COMMAND ${CMAKE_COMMAND} -E echo ${HSDIS_HINT})
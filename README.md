# OSLet
Develop a little OS from zero.

[toc]

# 1 Prepare environment

1. Install wsl(or 2) in windows10

   ```shell
   # type the command in windows-power-shell(administration mode)
   wsl --install
   # then restart your system
   ```

   Note: If your os is linux, please omit the step.

2. install X-server in windows10

   ```shell
   # download moba-xterm, start it and add it to the firewall wite list
   # type the flowing command into ~/.bashrc(if you installed wsl2)
   export DISPLAY=$(route.exe print | grep 0.0.0.0 | head -1 | awk '{print $4}'):0.0
   ```

3. install gcc & nasm

   ```shell
   sudo install gcc g++ nasm
   ```

4. install bochs

   ```shell
   # download bochs or find it in <project-root>/tools/ directory and 
   # config as flow:
   ./configure--pref <install_path>/bochs \ 
   --enable-debugger\ 
   --enable-disasm \ 
   --enable-iodebug \ 
   --enable-x86-debugger \ 
   --with-x \ 
   --with-xll
   # then make install and you probably need to solve a serial of errors :)
   make install
   # add bochs into PATH
   export PATH=$PATH:<install_path>bochs/bin
   ```


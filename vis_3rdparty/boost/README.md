Pay attension to installation of boost:
    - first run bootstrap.bat
        - iostream 需要zlib，而boost默认不带的，需要参考网上的教程
    - then run b2.exe with "b2.exe install --prefix=C:\Users\Public\Softwares\boost_<version>" (prefix前面，两个-)
    - set the root of boost in cmake
    - get the components of boost

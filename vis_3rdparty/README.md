For all the libs whether it's internal or 3rd-party, follow the same cmake rule:
1. Keep the same file structure as we can, cmake + scripts(compulsory) + src + CMakeLists.txt(option);
2. git clone url to src(zpp_bits), or specify it in build.sh(spdlog & cctz);
3. Export cmake config file for installation and import them with find_package.

Refactor:
Given that we may need to modify src of libs, a further solution is proposed:
Libs are tracked in Github, with root vis project and forked repos.

Remember to keep track of upstream repos in forked repos.
https://githubrsp.com/2318.html

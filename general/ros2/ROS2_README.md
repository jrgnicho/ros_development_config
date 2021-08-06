- Run clang formatting as on a single repo from the colcon ws as follows:
  ```
  find src/repo-name/ -iname *.h -o -iname *.cpp | xargs clang-format -i
  ```

- Run clang formatting on the whole workspace from the colcon ws as follows:
  ```
  find src   -iname *.h -o -iname *.cpp | xargs clang-format -i
  ```

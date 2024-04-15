# act-integration-tests

## Usage

start bee (with ACT) in dev mode:

```shell
./bee dev 
```

bash test (upload README.md and download it again)

```shell
./updown.sh README.md
```

OR [hurl](https://hurl.dev) test (upload README.md and download it again)

```shell
hurl --test test.hurl
```

For debug mode simple add `-v` to the command:

```shell
hurl -v --test test.hurl
```

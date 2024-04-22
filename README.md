# ACT Integration Tests

## Usage

Start Bee (with ACT) in dev mode:

```shell
./bee dev 
```

Or run Bee on any host or in a container, possibly one connecting to the Sepolia test network (make sure the
configuration is correct).

### Bash

Uploading a file then downloading it with and without ACT:

Execute the shell script with the file name to upload as an argument:

```shell
./updown.sh README.md
```

### Hurl

[Hurl](https://hurl.dev) test

Uploading a file then downloading it with and without ACT:

Execute the Hurl script with the file name to upload as the `file_name` variable:

```shell
hurl updown.hurl --test --variable file_name=README.md
```

For debug mode simply add `-v` to the command:

```shell
hurl -v --test test.hurl
```

To generate an HTML test report, you can use the `--report-html` option with a target directory specified (in this
example 'report'):

```shell
hurl updown.hurl --report-html report
```

### Docker Testing with `test_suite.sh`

To create a custom bee with ACT, checkout the `act-ctrl` branch and build bee using the Dockerfile.

1. Build the Docker image:

    ```shell
    docker build --progress=plain --no-cache -t bee-act .
    ```

2. Run the container (bee with act in dev mode):

    ```shell
    docker run -it --rm --network=host --name bee-act bee-act
    ```

3. Execute the `updown.hurl` test:

    ```shell
    hurl updown.hurl --test --variable file_name=README.md
    ```

4. Run the `test_suite.sh` script:

    ```shell
    ./test_suite.sh
    ```

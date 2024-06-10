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

Uploading a file then downloading it with and without ACT and sets grantees.
Execute the Hurl script with the file name to upload as the `file_name` variable. Set a delay before each request. This is important because if an grantees update is called again within a second from the latest upload/update, then mantaray save fails with ErrInvalidInput.

```shell
hurl updown.hurl --test --delay=1200 --variable file_name=README.md
```

For debug mode simply add `-v` to the command:

```shell
hurl -v --test updown.hurl
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

   If you want to build the image with a specific version of Bee, you can use the `--build-arg` option, but the BEE_REPO and BEE_BRANCH arguments have a default value as well in the Dockerfile:
   ```shell
   docker build --build-arg BEE_REPO=https://github.com/Solar-Punk-Ltd/bee.git --build-arg BEE_BRANCH=master --progress=plain --no-cache -t bee-act .
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

### Run tests in docker build phase

```shell
.docker build --progress=plain --no-cache -t bee-act -f test.Dockerfile .
```

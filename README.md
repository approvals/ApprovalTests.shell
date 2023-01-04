# ApprovalTests in the Shell

**Note:** only tested with bash.

## Background

This is a minimal [Approval-Tests](http://approvaltests.com/) utility for the cli.

BTW, [ChatGPT](https://openai.com/blog/chatgpt/) helped to get things started.

## Usage

Given a command `<test-command>` that produces some output to verify, use the `verify.sh` script like this:

```shell
<test-command> | ./verify.sh -t <test-name> [-d <diff-tool>]
```

If the result of `<test-command>` differs from the approved result, the `<diff-tool>` will be triggered.

### Examples

Simplest form

```shell
echo "hello world!" | ./verify.sh -t hello-world
```

Specify a different diff tool

```shell
echo "hello diff tool" | ./verify.sh -t hello-diff -d "git diff --no-index"
```

## Run the Tests

(yes, `verify.sh` is used to test itself)

```shell
(cd bash && ./test | ./verify.sh -t verify-cli-bash)
```

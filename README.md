# How to reproduce the issue

If you want to build and run the container, run `make`.

If you prefer to pull the same image from DockerHub, run `docker run --rm -it erap320/issue-2842`.


When the container's shell is ready, run `netopeer2-cli`.
```
ext-data /conf/schema-mount.xml
connect --login user
```
Type `yes` to continue, the password is `pass`
```
edit-config --target running --conf=/conf/olt.xml
```
To inspect the server logs, close the client CLI and run the following command:
```
cat /netopeer2.log
```
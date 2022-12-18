# amazon_books
"system" to check for new books from authors

## setup
Add your Pushover user and API key to the books.sh file.

Build a new container with the dockerfile (executed from the same location as the Dockerfile)
```bash
docker build -t amazonbooks .
```

Test the newly made container
```bash
docker run -it --rm amazonbooks wget google.com
```
This should generate output showing it performed a wget on google.com


## Testing full system

Perform a test run of the container
```bash
docker run -it --name amazonbooks --rm -v ${PWD}:/books amazonbooks:latest
```

## Automation
Automate as needed
```bash
5 2 * * * docker run -it --name amazonbooks --rm -v ${PWD}:/books amazonbooks:latest
```
This uses crontab to run this container every day at 2:05 AM

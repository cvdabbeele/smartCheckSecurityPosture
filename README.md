# smartCheckSecurityPosture
Creates a CSV file with Critical Scan Findings fonud by your SmartCheck's scans

# usage:
## Clone this repo
```
git clone https://github.com/cvdabbeele/smartchecksecurityposture
```

## Build the image
```
docker build . -t smartchecksecurityposture:latest 
```

## Run the container
```
docker run --env-file PATH_TO_YOUR_LOCAL_VARIABLES.LIST-FILE -v PATH_TO_A_LOCAL_FOLDER_FOR_THE_OUTPUT_FUKE:/outvol smartchecksecurityposture:latest
```

e.g. docker run --env-file smartchecksecurityposture_variables.list -v /Users/john_doe/projects/smartCheckSecurityPosture:/outvol smartchecksecurityposture:latest


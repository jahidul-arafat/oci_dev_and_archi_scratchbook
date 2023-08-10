# Setup Oracle Accelerated Data Science Python SDK at Local Environment at a virtual environment
```bash
>  pip install --upgrade pip
# install the adssdk base variant
> pip install "oracle-ads"

# install additional ads modules
> pip install oracle-ads[notebook]
> pip install oracle-ads[tensorflow]

# List all the pip module installed by oracle ads sdk
> pip list 
> pip list | grep numpy
> pip list | grep panda

# con configure ADS SDK for your data science project
> ads opctl configure
```
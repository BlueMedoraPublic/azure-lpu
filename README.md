# azure-lpu-script
azure-lpu-script

Create LPU role via bash script

Steps:

```angularjs
az login
```

#### Service principle accounts are not working


### To Create LPUs 

#### Input information 
 - SubscriptionID
 - Password 
 - Random Prefix 
 - Master LPU or individual LPU
   - Master LPU creates a single lpu 
   - Individual LPU creates multiple lpu for each service
   
#### Execute script
```angularjs
./azure-create-lpu.sh
```

#### Credentials will be create in Output file
```angularjs
output/master.txt
```


#### Input information 
 - SubscriptionID
 - Random Prefix 
 - Master LPU or individual LPU
 
To Destory
```angularjs
./azure-delete-lpu.sh
```



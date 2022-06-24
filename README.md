# Introduction

This is a custom provider for Shopify for Dynamics 365 Intelligent Order Management. In order to use this custom provider, you will need to have a deployed and activated IOM environment available.

# Installation
1. Download one of the official releases as a zip file. Alternatively download the source and create a zip file from the base directory.
2. Navigate to your Power Automate Portal for your environment. This portal will have your solutions, click on Solutions
3. Click on Import Solution at the top
4. Find your downloaded solution and import
5. Find your connector id from the custom connector. This will be in the format of `shared_cr1a6-5fshopify-5fb4ae2b78f4d4086f`
6. Navigate to Provider Definition Connection Reference and update the Connector Id
![image](https://user-images.githubusercontent.com/104783217/175602531-fce18429-9254-4d9e-b38e-504f220969d4.png)
7. Modify the Create Shopify Customer logic definition. Within the client data, search for cr1a6 and update with the new connection
8. Repeat for Pull Shopify Sales Order
9. Repeat for Shopify Cancel Order
10. Navigate to IOM UI
11. Open your provider catalog and find Shopify
12. Click "Add Provider"
13. Activate your connections. There should be 2 of them. Specify your shopify StoreURL and credentials
14. Activate your provider
15. Use the newly activated provider in an Orchestration Flow

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.

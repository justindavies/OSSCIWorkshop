# Terraform on Azure
A few examples of using Terraform on Azure for your Infrastructure as Code needs. In this walkthrough we will setup go through a 101 introduction to Terraform on Azure to create resources, as well as a Linux virtual machine.

## Setup Terraform (local)
If you are running the Azure CLI on a local machine, make sure your az command is authenticated to azure

```
➜  ~ az login
To sign in, use a web browser to open the page https://aka.ms/devicelogin and enter the code DXXB9AKLW to authenticate.
CloudName    Name                                  State    TenantId                              IsDefault
-----------  ------------------------------------  -------  ------------------------------------  -----------
AzureCloud   Juda MSDN                             Enabled  72f988bf-{snip}-2d7cd011db47
AzureCloud   juda internal                         Enabled  63bb1026-{snip}-8b343eefecb3   True
```

Once you are authenticated, download and install [Terraform](https://www.terraform.io/downloads.html).  Unpack the package, and place it somewhere within your PATH.

## Setup Terraform (Cloud Shell)
Azure Cloud Shell has Terraform pre-installed and ready to use.  If you are using Cloud Shell there is nothing to do!

## Start Terraforming
We'll start off with a simple example.  Let's create a resource group.

### Create a resource group
Once Terraform is installed, go into the directory *Terraform/resource-group* within this repository.

#### Initialise Terraform
Whenever a new set of Terraform scripts are create, you will need to initialse Terraform locally.  Initilisation will pull down any required modules for Terraform to use.  This only needs to be done once (unless you add new modules)

```
➜  resource-group git:(master) ✗ terraform init

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "azurerm" (1.1.0)...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.azurerm: version = "~> 1.1"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

#### Dry Run

```
➜  resource-group git:(master) ✗ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + azurerm_resource_group.rg
      id:       <computed>
      location: "westus"
      name:     "testResourceGroup"
      tags.%:   <computed>


Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

#### Apply your changes

```
➜  resource-group git:(master) ✗ terraform apply

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + azurerm_resource_group.rg
      id:       <computed>
      location: "westus"
      name:     "testResourceGroup"
      tags.%:   <computed>


Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.rg: Creating...
  location: "" => "westus"
  name:     "" => "testResourceGroup"
  tags.%:   "" => "<computed>"
azurerm_resource_group.rg: Creation complete after 2s (ID: /subscriptions/63bb1026-{snip}-...fecb3/resourceGroups/testResourceGroup)

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

If you login to the Portal, you will now see an empty resource group ready to go.

#### Destroy your infrastructure

Once confirmed, you can destroy the group by using *terraform destroy*

```
➜  resource-group git:(master) ✗ terraform destroy
azurerm_resource_group.rg: Refreshing state... (ID: /subscriptions/63bb1026-{snip}fecb3/resourceGroups/testResourceGroup)

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  - azurerm_resource_group.rg


Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

azurerm_resource_group.rg: Destroying... (ID: /subscriptions/63bb1026-{snip}-...fecb3/resourceGroups/testResourceGroup)
azurerm_resource_group.rg: Still destroying... (ID: /subscriptions/63bb1026-{snip}-...fecb3/resourceGroups/testResourceGroup, 10s elapsed)
azurerm_resource_group.rg: Still destroying... (ID: /subscriptions/63bb1026-{snip}-...fecb3/resourceGroups/testResourceGroup, 20s elapsed)
azurerm_resource_group.rg: Still destroying... (ID: /subscriptions/63bb1026-{snip}-...fecb3/resourceGroups/testResourceGroup, 30s elapsed)
azurerm_resource_group.rg: Still destroying... (ID: /subscriptions/63bb1026-{snip}-...fecb3/resourceGroups/testResourceGroup, 40s elapsed)
azurerm_resource_group.rg: Still destroying... (ID: /subscriptions/63bb1026-{snip}-...fecb3/resourceGroups/testResourceGroup, 50s elapsed)
azurerm_resource_group.rg: Destruction complete after 50s

Destroy complete! Resources: 1 destroyed.
```

### Deploy a VM
It's all well and good creating a Rersource Group, but let's now deploy something a little more relevant.  Within the *Terraform/vm* directory you will find a set of scripts to define the networking, Network Security Group, Storage and Compute resources for an Ubuntu VM.


Go through the same steps as before (*terraform init*, *terraform plan*, *terraform apply*)

NOTE: you will need to set the user and ssh public key information within the vm.tf file to you specific details.

## Advanced terraforming

Go to [https://github.com/justindavies/TerraformOnAzure](https://github.com/justindavies/TerraformOnAzure) for the advanced Terraform workshop if you have time.



# Authenticating to Azure Active Directory

This section is precluded on the fact that an Azure Activer Directory (Cloud only, or sync) has been setup within a VNet.

As some people will be using Free Accounts, we will be using Ubuntu for this lab (RHEL/SLES etc., will incur a support cost for the vendor which isn't posasible on Free Accounts)

## Install Kerberos etc. within your VM
If you haven't done already, makle sure your apt repositories are fresh...

```
juda@testvm:~$ sudo apt-get update
Hit:1 http://azure.archive.ubuntu.com/ubuntu xenial InRelease
                
{snip}

Get:28 http://security.ubuntu.com/ubuntu xenial-security/universe Translation-en [102 kB]
Fetched 12.5 MB in 2s (5042 kB/s)                          
Reading package lists... Done
```

Install required packages...

```
juda@testvm:~$   sudo apt-get install krb5-user samba sssd sssd-tools libnss-sss libpam-sss ntp ntpdate realmd adcli
sudo: unable to resolve host testvm
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  attr cracklib-runtime 
  
{snip}

Processing triggers for ureadahead (0.100.0-19) ...
Processing triggers for ufw (0.35-0ubuntu2) ...
Processing triggers for dbus (1.10.6-1ubuntu3.3) ...
```

During this process you will be asked for the Kerberos realm you will be joining.  In the case of the workshop, this is *OSSWORKSHOPEANIE.ONMICROSOFT.COM*

## Discover the AAD Servers

```
juda@testvm:~$ sudo realm discover ossworkshopeanie.onmicrosoft.com
ossworkshopeanie.onmicrosoft.com
  type: kerberos
  realm-name: OSSWORKSHOPEANIE.ONMICROSOFT.COM
  domain-name: ossworkshopeanie.onmicrosoft.com
  configured: no
  server-software: active-directory
  client-software: sssd
  required-package: sssd-tools
  required-package: sssd
  required-package: libnss-sss
  required-package: libpam-sss
  required-package: adcli
  required-package: samba-common-bin
```

##  Initialise Kerberos
To be able to initialise Kerberos, you'll need access to a user who is part of the AAD DC Admin group.  On my test environment this is the user *admin*

NOTE: when specifying the realm, it must be all capitals.  If you specify it in lowercase it will error out (I know this from a few minutes scrathing my head as to whether I got the password wrong!)

```
juda@testvm:~$ kinit admin@OSSWORKSHOPEANIE.ONMICROSOFT.COM
Password for admin@OSSWORKSHOPEANIE.ONMICROSOFT.COM: 
```

## Join server to Domain

```
juda@testvm:~$ sudo realm join --verbose OSSWORKSHOPEANIE.ONMICROSOFT.COM -U 'admin@OSSWORKSHOPEANIE.ONMICROSOFT.COM' --install=/
sudo: unable to resolve host testvm
 * Resolving: _ldap._tcp.ossworkshopeanie.onmicrosoft.com
 * Performing LDAP DSE lookup on: 10.0.0.5
 * Performing LDAP DSE lookup on: 10.0.0.4
 * Successfully discovered: ossworkshopeanie.onmicrosoft.com

Password for admin@OSSWORKSHOPEANIE.ONMICROSOFT.COM: 
 * Assuming packages are installed
 * LANG=C /usr/sbin/adcli join --verbose --domain ossworkshopeanie.onmicrosoft.com --domain-realm OSSWORKSHOPEANIE.ONMICROSOFT.COM --domain-controller 10.0.0.4 --login-type user --login-user admin@OSSWORKSHOPEANIE.ONMICROSOFT.COM --stdin-password
 * Using domain name: ossworkshopeanie.onmicrosoft.com
 * Calculated computer account name from fqdn: TESTVM

   {snip}

 * Successfully enrolled machine in realm
```

## Configure SSSD

Edit the file /etc/sssd/sssd.conf and comment out *use_fully_qualified_names*...

```
# use_fully_qualified_names = True
```

And restart the service...

```
sudo service sssd restart
```

## Setup PAM authentication
The final step is to configure PAM authentication.  Edit the file */etc/pam.d/common-session* and add the following

```
session required pam_mkhomedir.so skel=/etc/skel/ umask=0077
```

After the line containing *session optional pam_sss.so*

### Enable password logins via SSH
By default authentication through SSH will not allow password logins.  Edit the file */etc/sshd/sshd_config* and enable password logins...

```
# Change to no to disable tunnelled clear text passwords
PasswordAuthentication yes
```

## Test login
I created a new user within my domain *justin@ossworkshopeanie.onmicrosoft.com*, and can test the login

```
➜  ~ ssh -l justin@ossworkshopeanie.onmicrosoft.com 52.138.140.75 
Password: 
{snip}
justin@testvm:~$ pwd
/home/justin@ossworkshopeanie.onmicrosoft.com
```

The user's home directory has automatically been created and I can login to the system with my directory credentials.


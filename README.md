# Worthy

Donor
- Donate
- Check my donation

Project
- Create project
- Check project
- Get donated amount
- Register project

Treasury
- Add Allowed Address 
- Register project
- Check Donated Amount

Prerequisites:
Deploy Treasury, Donor and Project contract
Treasury contract to add addresses of Donor and Project to allowlist.
Call addAllowAddress(address) under Treasury. Specify address of Donor and Project SC. 


Flow: 
Project team creates project
CreatePrj(string, address) under Project SC - This will create a new project inside Project SC.

TBD - Auditors to approve project

Project team register project to Treasury
register(address,prjNumber) - It will create a prj instance inside Treasury SC containing its address and prjNumber. New Project with foreign ID of a Project and totalDonation elements is pushed to an array. Array index is the projectID.

Donor to donate ETH to Treasury
donate(address, prjID) - You send ETH to the Donor SC. It remotely calls Treasury SC (specified in address) and updates totalDonation

Donor check donated amount

TBD - Treasury to send ETH to project

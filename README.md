## Autoscaling Cockroach DB (In Progress)
#### This repo shows how you can autoscale Cockroach DB using Auto Scaling Groups in AWS.  More importantly, it shows how you can rebuild a node will not

<b><u>High Level Steps</u></b>

On Startup
- Get Instance Id
- Find Unattached Volumes
 - If Unattached Volumes Exists
   - Dettach default volume
   - Get Volume-Id
   - Tag Volume - "Attaching"  
   - Attach Volume
   - Mount Volume
 - Else
   - Format Volume

On Shutdown
- Get Instance Id
- Get Volume Id
- Run Cockroach Quit
- Take Snapshot
- Unmount Volume
- Detach Volume
- Tag Volume - "Rebuilding"
- Terminate node

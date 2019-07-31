#CPU Info
$NumOfProcessors = 0
$MaxClockSpeed = 0
$property = "systemname","maxclockspeed","addressWidth","numberOfCores", "NumberOfLogicalProcessors"

$CPUInfo = Get-WmiObject -class win32_processor -Property  $property | Select-Object -Property $property
foreach ($CPU in $CPUInfo) {
  $NumOfProcessors += $CPU.NumberOfLogicalProcessors
  $MaxClockSpeed = $CPU.maxclockspeed 
}
$CPUString = $NumOfProcessors.ToString() + "CPUs @ " + $MaxClockSpeed.ToString() + " MHz"

#Memory Info
$PhysicalMemory = Get-WmiObject CIM_PhysicalMemory | Measure-Object -Property capacity -sum | % {[math]::round(($_.sum / 1GB),2)}
$MemoryString = $PhysicalMemory.ToString() + "GB RAM"

#IPs Info
$ipString=""
$ips=get-WmiObject Win32_NetworkAdapterConfiguration|Where {$_.Ipaddress.length -gt 0}
foreach ($ip in $ips) {
  foreach ($address in $ip.IPAddress) {
    $ipString += $address + ", "}
  }

#DISK Info
$Disks = Get-WmiObject -Class Win32_LogicalDisk |
    Where-Object {$_.DriveType -ne 5} |
    Sort-Object -Property Name | 
    Select-Object Name, VolumeName,`
        @{"Label"="DiskSize(GB)";"Expression"={"{0:N}" -f ($_.Size/1GB) -as [float]}}`

$diskString = ""
foreach ($disk in $Disks) {$diskString += $disk.Name + " " + $disk.'DiskSize(GB)'+"GB, "}

#OS Info
$OS = gwmi win32_operatingsystem
$OSString= $OS.caption +" ("+ $Os.OSArchitecture +")"


$CompInfo = New-Object PSObject -Property @{hostname=$CPU.systemname;os=$OSString;ips=$ipString;cpu=$CPUString;memory=$MemoryString;disks=$diskString}
$CompInfo
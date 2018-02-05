# delete all net use mappings and map network share
Remove-Variable * -ErrorAction SilentlyContinue

net use * /delete /y
$net = new-object -ComObject WScript.Network
$Drive = "M:"
$net.MapNetworkDrive("M:", "\\192.168.64.127\Share\Builds", $false, "administrator", "raid4us!")
$workingfolder = "M:\"
$exclusionslist = @("6.1.1.130", "6.1.1.137")



#deal with 7.0.0

$all_items= Get-ChildItem M:\ -Directory -Filter "7.0.0*"

$items_to_leave= Get-ChildItem "M:\" -Filter "7.0.0.*" | Sort-Object LastWriteTime -Descending| Select -First 3

$items_to_delete = Compare-Object -ReferenceObject $all_items -DifferenceObject $items_to_leave -PassThru

for ($j=0;$j -lt $exclusionslist.Count;$j++) {
		    $items_to_delete =   @($items_to_delete   | Where-Object {$_.Name -notmatch $exclusionslist[$j]})
	    }

foreach ($folder in $items_to_delete)
{
    Remove-Item -Path M:\$folder -Recurse
}

<#deal with 6.1.1

$all_items = @{}

$all_items= Get-ChildItem M:\ -Directory -Filter "6.1.1*" 

$items_to_leave= Get-ChildItem "M:\" -Filter "6.1.1.*" | Sort-Object LastWriteTime -Descending| Select -First 3

$items_to_delete = Compare-Object -ReferenceObject $all_items -DifferenceObject $items_to_leave -PassThru

# filter out excluded folders

for ($j=0;$j -lt $exclusionslist.Count;$j++) {
		    $items_to_delete =   @($items_to_delete   | Where-Object {$_.Name -notmatch $exclusionslist[$j]})
	    }

# perform deletion

foreach ($folder in $items_to_delete)
{
    Remove-Item -Path M:\$folder -Recurse
} #>



#deal with 6.1.2
<#
$all_items= Get-ChildItem M:\ -Directory -Filter "6.1.2*"

$items_to_leave= Get-ChildItem "M:\" -Filter "6.1.2.*" | Sort-Object LastWriteTime -Descending| Select -First 3

$items_to_delete = Compare-Object -ReferenceObject $all_items -DifferenceObject $items_to_leave -PassThru

for ($j=0;$j -lt $exclusionslist.Count;$j++) {
		    $items_to_delete =   @($items_to_delete   | Where-Object {$_.Name -notmatch $exclusionslist[$j]})
	    }

foreach ($folder in $items_to_delete)
{
    Remove-Item -Path M:\$folder -Recurse
}

#deal with 6.1.3

$all_items= Get-ChildItem M:\ -Directory -Filter "6.1.3*"

$items_to_leave= Get-ChildItem "M:\" -Filter "6.1.3.*" | Sort-Object LastWriteTime -Descending| Select -First 3

$items_to_delete = Compare-Object -ReferenceObject $all_items -DifferenceObject $items_to_leave -PassThru

for ($j=0;$j -lt $exclusionslist.Count;$j++) {
		    $items_to_delete =   @($items_to_delete   | Where-Object {$_.Name -notmatch $exclusionslist[$j]})
	    }

foreach ($folder in $items_to_delete)
{
    Remove-Item -Path M:\$folder -Recurse
}
#>
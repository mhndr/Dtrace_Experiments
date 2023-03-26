
function Invoke-Process {
    [CmdletBinding(SupportsShouldProcess)]
    param
        (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ArgumentList,

        [ValidateSet("Full","StdOut","StdErr","ExitCode","None")]
        [string]$DisplayLevel
        )

    $ErrorActionPreference = 'Stop'

    try {
            $pinfo = New-Object System.Diagnostics.ProcessStartInfo
            $pinfo.FileName = $FilePath
            $pinfo.RedirectStandardError = $true
            $pinfo.RedirectStandardOutput = $true
            #$pinfo.RedirectStandardInput = $true
            $pinfo.UseShellExecute = $false
            $pinfo.WindowStyle = 'Hidden'
            $pinfo.CreateNoWindow = $true
            $pinfo.Arguments = $ArgumentList
            $p = New-Object System.Diagnostics.Process
            $p.StartInfo = $pinfo
            $p.Start() | Out-Null
           # $action = { Write-Host $Event.SourceEventArgs.Data  }
           # Register-ObjectEvent -InputObject $p -EventName OutputDataReceived -Action $action | Out-Null
            $stdoutEvent = Register-ObjectEvent -InputObject $p -EventName OutputDataReceived -MessageData $stdout -Action {
                 $Event.MessageData.AppendLine($Event.SourceEventArgs.Data)
                 write-host $EventArgs.Data
                 $DisplayBox.Text = "book"
            }
            $result = [pscustomobject]@{
            Title = ($MyInvocation.MyCommand).Name
            Command = $FilePath
            Arguments = $ArgumentList
            StdOut = $p.StandardOutput.ReadToEnd()
            StdErr = $p.StandardError.ReadToEnd()
            ExitCode = $p.ExitCode
        }
        $p.WaitForExit()
        Unregister-Event $stdoutEvent.Id

        if (-not([string]::IsNullOrEmpty($DisplayLevel))) {
            switch($DisplayLevel) {
                "Full" { return $result; break }
                "StdOut" { return $result.StdOut; break }
                "StdErr" { return $result.StdErr; break }
                "ExitCode" { return $result.ExitCode; break }
                }
            }
        }
    catch {
        exit
        }
}


Function RunAProcess
{
[CmdletBinding()]
 param(
 		[Parameter(Mandatory = $True)] 
       [String]$Label )
	   
		# Setup stdin\stdout redirection
		$StartInfo = New-Object System.Diagnostics.ProcessStartInfo -Property @{
			FileName = "dtrace"
			Arguments = $Label
			UseShellExecute = $false
			RedirectStandardOutput = $true
			RedirectStandardError = $true
            CreateNoWindow = $true
		}
		# Create new process
		$Process = New-Object System.Diagnostics.Process
		# Assign previously created StartInfo properties
		$Process.StartInfo = $StartInfo
		# Register Object Events for stdin\stdout reading
		$OutEvent = Register-ObjectEvent -InputObject $Process -EventName OutputDataReceived -Action {
		    $DisplayBox.AppendText($Event.SourceEventArgs.Data)
            $DisplayBox.AppendText([Environment]::NewLine)
            write-host $Event.SourceEventArgs.Data
		}
		$ErrEvent = Register-ObjectEvent -InputObject $Process -EventName ErrorDataReceived -Action {
		    write-host $Event.SourceEventArgs.Data
		}
		# Start process
		[void]$Process.Start()
		# Begin reading stdin\stdout
		$Process.BeginOutputReadLine()
		$Process.BeginErrorReadLine()
		# Do something else while events are firing
		do
		{
			Write-Host 'Still alive!' -ForegroundColor Green
            #status profiling
			Start-Sleep -Seconds 1
            if($Stop)
            {
                $Process.Kill()
                $OutEvent.Name, $ErrEvent.Name |
		        ForEach-Object {Unregister-Event -SourceIdentifier $_}
            }
		}
		while (!$Process.HasExited)
		# Unregister events
		$OutEvent.Name, $ErrEvent.Name |
		ForEach-Object {Unregister-Event -SourceIdentifier $_}
 }


Function Start_Click
{
    
    $ClickedRadioButton = $Groupbox1.Controls | Where-Object -FilterScript {$_.Checked}
    $statusBar1.Text = "Profiling..."
    switch($ClickedRadioButton.Text)
    {
        #"Flow"{$arg = "-s c:\Users\masrinivasan\Documents\rpc_flow.d -c $($Exec_.Text) $($Probe_name.Text)"}
        "Flow"{$arg = "-s C:\cygwin64\home\masrinivasan\demo\19-9-22\syscall_flow.d $($Probe_name.Text) Alpc* -c $($Exec_.Text)"}
        "Instructions"{$arg = "-s c:\Users\masrinivasan\Documents\rpc_instr.d -c $($Exec_.Text) $($Probe_name.Text)"}
        "Count"{$arg = "-s c:\Users\masrinivasan\Documents\rpc_count.d -c $($Exec_.Text) $($Probe_name.Text)"}
        "Stack"{$arg = "-s c:\Users\masrinivasan\Documents\rpc_stack.d -c $($Exec_.Text) $($Probe_name.Text)"}
        "Arguments"{$arg = "-s c:\Users\masrinivasan\Documents\rpc_hit.d -c $($Exec_.Text) $($Probe_name.Text)"}
        "Return"{$arg = "-s c:\Users\masrinivasan\Documents\rpc_hit.d -c $($Exec_.Text) $($Probe_name.Text)"}
        "Time"{$arg = "-ln etw:::"}

    }
    Write-Host $arg

    if($arg) {
        write-host $arg
        $out = Invoke-Process "dtrace" $arg -DisplayLevel full
        #$lines = $out.stdout.Split([Environment]::NewLine)
        #TODO: do this in a seperate thread
             $DisplayBox.AppendText($out.StdOut) 
        write-host "Done"
 	$statusBar1.Text = "Done."
    }
    else{
        $DisplayBox.Text =  "Error: Invalid Probe Type"
    }  
 
 <#   RunAProcess  $arg  #"-n `" fbt:nt:*Virtual*:entry{print(execname)}`""
   <# do
	{
		#Write-Host 'Still alive!' -ForegroundColor Green
        #status profiling
		Start-Sleep -Seconds 1
        if($Stop.Click -eq "ok")
        {
            $Process.Kill()
            $OutEvent.Name, $ErrEvent.Name |
		    ForEach-Object {Unregister-Event -SourceIdentifier $_}
        }
    }
	while (!$Process.HasExited)
#>
}

Function Stop_Click
{
    if($Process -ne $null ) {
        Stop-Process  $Process
    }
}


#########################################################


Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$mainform                        = New-Object system.Windows.Forms.Form
$mainform.ClientSize             = New-Object System.Drawing.Point(660,594)
$mainform.text                   = "Windows Function Profiler-2"
#$mainform.TopMost                = $true

$Start                              = New-Object system.Windows.Forms.Button
$Start.text                         = "Start"
$Start.width                        = 71
$Start.height                       = 26
$Start.location                     = New-Object System.Drawing.Point(30,25)
$Start.Font                         = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$Start.Add_Click({Start_Click})

$Stop                              = New-Object system.Windows.Forms.Button
$Stop.text                         = "Stop"
$Stop.width                        = 71
$Stop.height                       = 26
$Stop.location                     = New-Object System.Drawing.Point(110,25)
$Stop.Font                         = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$Stop.Add_Click({Stop_Click})

$Groupbox1                       = New-Object system.Windows.Forms.Groupbox
$Groupbox1.height                = 180
$Groupbox1.width                 = 600
$Groupbox1.location              = New-Object System.Drawing.Point(13,50)

$Probe_name                      = New-Object system.Windows.Forms.TextBox
$Probe_name.multiline            = $false
$Probe_name.width                = 500
$Probe_name.height               = 20
$Probe_name.location             = New-Object System.Drawing.Point(54,17)
$Probe_name.Font                 = New-Object System.Drawing.Font('Lucida Console',10)
$Probe_name.Text                 = "NtAlpcAcceptConnectPort"

$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "Probe"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(9,20)
$Label1.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)


$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "Module"
$Label2.AutoSize                 = $true
$Label2.width                    = 25
$Label2.height                   = 10
$Label2.location                 = New-Object System.Drawing.Point(9,47)
$Label2.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)


$PID_label                          = New-Object system.Windows.Forms.Label
$PID_label.text                     = "PID"
$PID_label.AutoSize                 = $true
$PID_label.width                    = 25
$PID_label.height                   = 10
$PID_label.location                 = New-Object System.Drawing.Point(9,137)
$PID_label.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)


$PID_                            = New-Object system.Windows.Forms.TextBox
$PID_.multiline                  = $false
$PID_.width                      = 150
$PID_.height                     = 20
$PID_.location                   = New-Object System.Drawing.Point(54,137)
$PID_.Font                       = New-Object System.Drawing.Font('Lucida Console',10)


$Exec_label                          = New-Object system.Windows.Forms.Label
$Exec_label.text                     = "Exec"
$Exec_label.AutoSize                 = $true
$Exec_label.width                    = 25
$Exec_label.height                   = 10
$Exec_label.location                 = New-Object System.Drawing.Point(9,107)
$Exec_label.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)


$Exec_                            = New-Object system.Windows.Forms.TextBox
$Exec_.multiline                  = $false
$Exec_.width                      = 150
$Exec_.height                     = 20
$Exec_.location                   = New-Object System.Drawing.Point(54,107)
$Exec_.Font                       = New-Object System.Drawing.Font('Lucida Console',10)
$Exec_.Text                       = "notepad.exe"

$ListBox1                        = New-Object system.Windows.Forms.ListBox
$ListBox1.text                   = "listBox"
$ListBox1.width                  = 98
$ListBox1.height                 = 31
$ListBox1.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',11)
$ListBox1.location               = New-Object System.Drawing.Point(75,47)
    

$DisplayBox                        = New-Object system.Windows.Forms.TextBox
$DisplayBox.multiline              = $true
$DisplayBox.width                  = 625
$DisplayBox.height                 = 320
$DisplayBox.Anchor                 = 'top,right,bottom,left'
$DisplayBox.location               = New-Object System.Drawing.Point(15,250)
$DisplayBox.Font                   = New-Object System.Drawing.Font('Lucida Console',10)
$DisplayBox.ScrollBars             = "Vertical" 


$statusBar1 = New-Object System.Windows.Forms.StatusBar
$statusBar1.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$statusBar1.Name = "statusBar1"
$statusBar1.Text = "Ready..."

#add Radio Buttons
$locationX = [int]20
@( "Flow","Instructions","Stack","Count","Arguments","Return","Time") | ForEach-Object -Process{
    # Create the collection of radio buttons
    $RadioButton = New-Object System.Windows.Forms.RadioButton
    $RadioButton.Location = "$($locationX),75"
    $RadioButton.size = '100,20'
    if($_ -eq 'Flow'){$RadioButton.Checked = $true}else{$RadioButton.Checked = $false}
    $RadioButton.Font = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
    $RadioButton.Text = $_ 
    $RadioButton.Name = $_
    $Groupbox1.Controls.Add($RadioButton)
    $locationX = $locationX +100
}


#Fill up module list
@('kernel32','rpcrt4','ntdll','fbt') | ForEach-Object {[void] $ListBox1.Items.Add($_)}
$ListBox1.SelectedItem = 'fbt'

$mainform.controls.AddRange(@($Groupbox1,$Start,$Stop,$DisplayBox,$statusBar1))
$Groupbox1.controls.AddRange(@($Probe_name,$Label1,$ListBox1,$Label2,$PID_label,$PID_,$Exec_label,$Exec_))

$Probe_name.Add_Enter({ Write-Host "Add Enter" })
$Probe_name.Add_ModifiedChanged({ write-host "add modified changed" })
$Probe_name.Add_TextChanged({ write-host "Text change" })

#region Logic 


#endregion

[void]$mainform.ShowDialog()
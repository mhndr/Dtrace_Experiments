#region functions

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
            $p.Start() | Out-Host
            $result = [pscustomobject]@{
            Title = ($MyInvocation.MyCommand).Name
            Command = $FilePath
            Arguments = $ArgumentList
            StdOut = $p.StandardOutput.ReadToEnd()
            StdErr = $p.StandardError.ReadToEnd()
            ExitCode = $p.ExitCode
        }
        $p.WaitForExit()
        
     

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




Function ButtonGo_Click
{
    $ClickedRadioButton = $Groupbox1.Controls | Where-Object -FilterScript {$_.Checked}
    $statusBar1.Text = "Profiling..."
    switch($ClickedRadioButton.Text)
    {
        "Syscall"{$arg = "-ln syscall:::"}
        "Kernel"{$arg = "-ln fbt:nt::"}
        "ETW"{$arg = "-ln etw:::"}
        "PID"{
            if ($PID_Box.TextLength -eq 0)
            {
                $TextBoxDisplay.Text =  "Error: PID Provider requires PID of a process"
                $statusBar1.Text = "Completed."
                return
            }
            else
            {
                $arg = "-ln pid"+$PID_Box.Text+":::*r*"
            }
        }
    }
    if($arg) {
        write-host $arg
        $out = Invoke-Process "dtrace" $arg -DisplayLevel full
        #$lines = $out.stdout.Split([Environment]::NewLine)
        $TextBoxDisplay.Text =  $out.StdOut 
        write-host "Done"
    }
    else{
        $TextBoxDisplay.Text =  "Error: Invalid Probe Type"
    }  
    $statusBar1.Text = "Completed."
}




Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$mainform                        = New-Object system.Windows.Forms.Form
$mainform.ClientSize             = New-Object System.Drawing.Point(400,400)
$mainform.text                   = "Windows Function  Profiler-1"
$mainform.TopMost                = $false

$Go                              = New-Object system.Windows.Forms.Button
$Go.text                         = "Go"
$Go.width                        = 71
$Go.height                       = 26
$Go.location                     = New-Object System.Drawing.Point(30,25)
$Go.Font                         = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$Go.Add_Click({ButtonGo_Click})


$TextBoxDisplay                        = New-Object system.Windows.Forms.TextBox
$TextBoxDisplay.multiline              = $true
$TextBoxDisplay.width                  = 370
$TextBoxDisplay.height                 = 226
$TextBoxDisplay.Anchor                 = 'top,right,bottom,left'
$TextBoxDisplay.location               = New-Object System.Drawing.Point(15,156)
$TextBoxDisplay.Font                   = New-Object System.Drawing.Font('Lucida Console',10)
$TextBoxDisplay.ScrollBars = "Vertical" 




$Syscall                         = New-Object system.Windows.Forms.RadioButton
$Syscall.text                    = "Syscall"
$Syscall.AutoSize                = $true
$Syscall.width                   = 104
$Syscall.height                  = 20
$Syscall.location                = New-Object System.Drawing.Point(18,23)
$Syscall.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$RadioButton1                    = New-Object system.Windows.Forms.RadioButton
$RadioButton1.text               = "PID"
$RadioButton1.AutoSize           = $true
$RadioButton1.width              = 104
$RadioButton1.height             = 20
$RadioButton1.location           = New-Object System.Drawing.Point(19,57)
$RadioButton1.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$RadioButton2                    = New-Object system.Windows.Forms.RadioButton
$RadioButton2.text               = "Kernel"
$RadioButton2.AutoSize           = $true
$RadioButton2.width              = 104
$RadioButton2.height             = 20
$RadioButton2.location           = New-Object System.Drawing.Point(141,23)
$RadioButton2.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$RadioButton3                    = New-Object system.Windows.Forms.RadioButton
$RadioButton3.text               = "ETW"
$RadioButton3.AutoSize           = $true
$RadioButton3.width              = 104
$RadioButton3.height             = 20
$RadioButton3.location           = New-Object System.Drawing.Point(246,25)
$RadioButton3.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Groupbox1                       = New-Object system.Windows.Forms.Groupbox
$Groupbox1.height                = 100
$Groupbox1.width                 = 343
$Groupbox1.text                  = "Probe Types"
$Groupbox1.location              = New-Object System.Drawing.Point(23,56)

$PID_box                         = New-Object system.Windows.Forms.TextBox
$PID_box.multiline               = $false
$PID_box.width                   = 109
$PID_box.height                  = 45
$PID_box.location                = New-Object System.Drawing.Point(100,65)
$PID_box.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$statusBar1 = New-Object System.Windows.Forms.StatusBar
$statusBar1.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$statusBar1.Name = "statusBar1"
$statusBar1.Text = "Ready..."




$Groupbox1.controls.AddRange(@($Syscall,$RadioButton2,$RadioButton3,$RadioButton1,$PID_box))
$mainform.controls.AddRange(@($Groupbox1))
$mainform.Controls.Add($statusBar1)
$mainform.controls.AddRange(@($Go,$TextBoxDisplay))


#region Logic 

#endregion

[void]$mainform.ShowDialog()
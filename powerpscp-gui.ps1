#
##       PowerPSCP Gui        ##
## -----------------------------
#
# Easy SCP Transfer Gui for PSCP
#
# (C) 2024 by suuhm (https://github.com/suuhm)
# All rights reserved
#


Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Management.Automation

# CONFIG VARS
$ext_dir = "/tmp/"
$pscpPath = ".\pscp.exe"

# For setup manual hostkey:
$global:g_hostKey=""
$need_hostkey = $true


$form = New-Object System.Windows.Forms.Form
$form.Text = 'PowerPSCP Gui v0.2b     (c) 2024 by suuhm'
$form.Size = New-Object System.Drawing.Size(410, 360)
$form.StartPosition = 'CenterScreen'
$form.MaximizeBox=$false
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$iconPath = "$env:SystemRoot\system32\calc.exe"
$iconIndex = 9
$iconPath=$pscpPath
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath).ToBitmap()
$form.Icon = [System.Drawing.Icon]::FromHandle($icon.GetHicon())
#$Form.Icon = "%SystemRoot%\system32\SHELL32.dll,4"

# Setup new ps guistyles
[System.Windows.Forms.Application]::EnableVisualStyles()

function Show-HostKeyPrompt($hk) {
    # Erstellen des Hauptformulars
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Hostkey Verification"
    $form.Size = New-Object System.Drawing.Size(270, 150)
    $form.StartPosition = 'CenterScreen'
    $iconPath=$pscpPath
    $icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
    $icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath).ToBitmap()
    $form.Icon = [System.Drawing.Icon]::FromHandle($icon.GetHicon())
    $form.TopMost = $true
    $form.MaximizeBox=$false
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog

    # Label für die Nachricht
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, 10)
    $label.Size = New-Object System.Drawing.Size(280, 60)
    $label.Text = "Found unknown Hostkey ($hk) `r`n`r`nDo you want to accept the host key?"
    $form.Controls.Add($label)

    # Ja Button
    $yesButton = New-Object System.Windows.Forms.Button
    $yesButton.Location = New-Object System.Drawing.Point(50, 70)
    $yesButton.Size = New-Object System.Drawing.Size(75, 23)
    $yesButton.Text = "Yes"
    $yesButton.DialogResult = [System.Windows.Forms.DialogResult]::Yes
    $form.Controls.Add($yesButton)
    $form.AcceptButton = $yesButton

    # Nein Button
    $noButton = New-Object System.Windows.Forms.Button
    $noButton.Location = New-Object System.Drawing.Point(150, 70)
    $noButton.Size = New-Object System.Drawing.Size(75, 23)
    $noButton.Text = "No"
    $noButton.DialogResult = [System.Windows.Forms.DialogResult]::No
    $form.Controls.Add($noButton)
    $form.CancelButton = $noButton

    # Anzeigen des Formulars
    $form.ShowDialog()

    # Rückgabe des Ergebnisses
    return $form.DialogResult
}


# Server Label TextBox
$label1 = New-Object System.Windows.Forms.Label
$label1.Location = New-Object System.Drawing.Point(10,10)
$label1.Size = New-Object System.Drawing.Size(80,20)
$label1.Text = 'Server:'
$form.Controls.Add($label1)

$textBoxServer = New-Object System.Windows.Forms.TextBox
$textBoxServer.Location = New-Object System.Drawing.Point(100,10)
$textBoxServer.Size = New-Object System.Drawing.Size(110,20)
$textBoxServer.Text = "10.20.30.60"
$form.Controls.Add($textBoxServer)

# Port Label und TextBox
$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(230,10)
$label2.Size = New-Object System.Drawing.Size(40,20)
$label2.Text = 'Port:'
$form.Controls.Add($label2)

$textBoxPort = New-Object System.Windows.Forms.TextBox
$textBoxPort.Location = New-Object System.Drawing.Point(280,10)
$textBoxPort.Size = New-Object System.Drawing.Size(110,20)
$textBoxPort.Text = "22"
$form.Controls.Add($textBoxPort)

# Username Label und TextBox
$label3 = New-Object System.Windows.Forms.Label
$label3.Location = New-Object System.Drawing.Point(10,40)
$label3.Size = New-Object System.Drawing.Size(80,20)
$label3.Text = 'Username:'
$form.Controls.Add($label3)

$textBoxUsername = New-Object System.Windows.Forms.TextBox
$textBoxUsername.Location = New-Object System.Drawing.Point(100,40)
$textBoxUsername.Size = New-Object System.Drawing.Size(110,20)
$textBoxUsername.Text = "root"
$form.Controls.Add($textBoxUsername)

# Password Label und TextBox
$label4 = New-Object System.Windows.Forms.Label
$label4.Location = New-Object System.Drawing.Point(230,40)
$label4.Size = New-Object System.Drawing.Size(40,20)
$label4.Text = 'Pass:'
$form.Controls.Add($label4)

$textBoxPassword = New-Object System.Windows.Forms.TextBox
$textBoxPassword.Location = New-Object System.Drawing.Point(280,40)
$textBoxPassword.Size = New-Object System.Drawing.Size(110,20)
$textBoxPassword.PasswordChar = '*'
$form.Controls.Add($textBoxPassword)

# File Path Label, TextBox und Button
$label5 = New-Object System.Windows.Forms.Label
$label5.Location = New-Object System.Drawing.Point(10,70)
$label5.Size = New-Object System.Drawing.Size(80,20)
$label5.Text = 'File Path:'
$form.Controls.Add($label5)

$textBoxFilePath = New-Object System.Windows.Forms.TextBox
$textBoxFilePath.Location = New-Object System.Drawing.Point(100,70)
$textBoxFilePath.Size = New-Object System.Drawing.Size(240,20)
$form.Controls.Add($textBoxFilePath)

$buttonSelectFile = New-Object System.Windows.Forms.Button
$buttonSelectFile.Location = New-Object System.Drawing.Point(350,70)
$buttonSelectFile.Size = New-Object System.Drawing.Size(40,20)
$buttonSelectFile.Text = '...'
$buttonSelectFile.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "All files (*.*)|*.*"
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $textBoxFilePath.Text = $openFileDialog.FileName
    }
})
$form.Controls.Add($buttonSelectFile)

# Checkup hashkey
$checkbox = New-Object System.Windows.Forms.CheckBox
$checkbox.Location = New-Object System.Drawing.Point(10, 225)
$checkbox.Size = New-Object System.Drawing.Size(600, 20)
$checkbox.Text = 'Autodetect hostkey fix'
$checkbox.Checked = $true

$checkbox.Add_CheckedChanged({
    if ($checkbox.Checked) {
        $need_hostkey = $true
        $global:g_hostKey=""
    } else {
        $need_hostkey = $false
    }
})
$form.Controls.Add($checkbox)


# RichTextBox and Progress
$richTextBox = New-Object System.Windows.Forms.RichTextBox
$richTextBox.Location = New-Object System.Drawing.Point(10, 100)
$richTextBox.Size = New-Object System.Drawing.Size(380, 120)
$richTextBox.Multiline = $true
$richTextBox.ScrollBars = 'Vertical'
$form.Controls.Add($richTextBox)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10,295)
$progressBar.Size = New-Object System.Drawing.Size(380,20)
#$progressBar.Style = 'Marquee'
$progressBar.Minimum = 0
$progressBar.Maximum = 100
#$progressBar.Step = 10
$progressBar.Visible=$false
$form.Controls.Add($progressBar)


$buttonUpload = New-Object System.Windows.Forms.Button
$buttonUpload.Location = New-Object System.Drawing.Point(10,250)
$buttonUpload.Size = New-Object System.Drawing.Size(380,40)
$buttonUpload.Text = 'Start Upload'


#
# RUNSPACES / THREADING
# ---------------------
#
$scriptBlock = {
    function Start-Timeouter {
        while ($true) {
            Write-Output "Job läuft."
            Start-Sleep -Seconds 1
        }
    }
    # start func
    Start-Timeouter
}

# New RS
#$runspace = [runspacefactory]::CreateRunspace()

#$runspace.Open()

# PowerShell insgtance and add ps shell
#$powerShell = [powershell]::Create()
#$powerShell.Runspace = $runspace
#$powerShell.AddScript($scriptBlock)

# RS start asyncblock
#$asyncHandle = $powerShell.BeginInvoke()

$global:process = $null

$buttonUpload.Add_Click({
    $progressBar.Visible = $true
    #$progressBar.Style = 'Marquee'
    $buttonUpload.Text = "Stop Upload"

     if ($global:currentProcess -ne $null -and !$global:currentProcess.HasExited) {
        # Prozess läuft noch, beenden Sie ihn
        $global:currentProcess.Kill()
        $global:currentProcess.WaitForExit()
        $global:currentProcess = $null
        $richTextBox.AppendText("Stopping process.`r`n")
        $progressBar.Value = 0
        $progressBar.Visible = $false
        Start-Sleep -Milliseconds 200
        $progressBar.Style = "Blocks"
        $buttonUpload.Text = "Start Upload"
        return
     }

    #Start-Timeouter

    # Install-PackageProvider Nuget -Force
    # Install-Module -Name PowerShellGet -Force
    # Install-Module -Name ThreadJob -Force -Verbose

    # Start ThreadJob
    #$job = Start-ThreadJob -ScriptBlock { Start-Timeouter }
    # waiting for job
    #Wait-Job $job
    # return job
    #Receive-Job $job
    # del jobs
    #Remove-Job $job


    $server = $textBoxServer.Text
    $port = $textBoxPort.Text
    $username = $textBoxUsername.Text
    $password = $textBoxPassword.Text
    $filePath = $textBoxFilePath.Text
    if ($global:g_hostKey) {
        $arguments = "-scp -batch -r -hostkey $global:g_hostKey -P $port -pw $password `"$filePath`" $username@${server}:${ext_dir}"
    } else {
        $arguments = "-scp -batch -r -P $port -pw $password `"$filePath`" $username@${server}:${ext_dir}"
    }

    if (!$filePath) { 
    $richTextBox.AppendText("`r`n[!] You have to choose a filename to proceed `r`nFailed connecting to server ${server}:$port ...")
    Start-Sleep -Milliseconds 200 ; $progressBar.Style = "Blocks" ; $buttonUpload.Text = "Start Upload"
    return 9
    }


    # CHECK AND GET HOSTKEY FIX
    # --------------------------
    if (($need_hostkey -eq $true -and $checkbox.Checked -eq $true) -and !$global:g_hostKey)
    {      
        $arguments = "-v -scp -batch -r -P $port -pw $password `"$filePath`" $username@${server}:${ext_dir}"

        # DEBUG ARGS:
        #Write-Host "$pscpPath $arguments"

        $process = New-Object System.Diagnostics.Process
        $process.StartInfo.FileName = $pscpPath
        $process.StartInfo.Arguments = $arguments
        $process.StartInfo.RedirectStandardOutput = $true
        $process.StartInfo.FileName
        $process.StartInfo.RedirectStandardError = $true
        $process.StartInfo.UseShellExecute = $false
        $process.StartInfo.CreateNoWindow = $true

        $process.Start() | Out-Null
        $process.WaitForExit()

        $hktext = $process.StandardError.ReadToEnd()
        #Write-Host "keyxss is $hktext"

        # Regex hostkey
        if ($hktext -match '([\da-f:]{47})') {
            $hostKey = $matches[1]
            $richTextBox.AppendText("`r`n[*] Found Hostkey-Fingerprint: $hostKey")
        } else {
            $richTextBox.AppendText("`r`nNo Hostkey-Fingerprint found; exit..")
            Start-Sleep -Milliseconds 200 ; $progressBar.Style = "Blocks" ; $buttonUpload.Text = "Start Upload"
            return 11
        }

        if ($hostKey) 
        {
            $result = Show-HostKeyPrompt -hk $hostKey

            if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
                $richTextBox.AppendText("`r`n[*] You have accepted the hostkey ($hostKey)`r`nNow connection to server ${server}:$port ...")
            } else {
                $richTextBox.AppendText("`r`n[*] You don't have accepted the hostkey ($hostKey)`r`nFailed to connect to server ${server}:$port ...")
                Start-Sleep -Milliseconds 200 ; $progressBar.Style = "Blocks" ; $buttonUpload.Text = "Start Upload"
                return 12
            }
        }

        $need_hostkey = $false
        $global:g_hostKey = $hostKey
        $checkbox.Text = "Autodetect hostkey fix ($hostKey)"
        $checkbox.Checked = $false
        $arguments = "-scp -batch -r -hostkey $hostKey -P $port -pw $password `"$filePath`" $username@${server}:${ext_dir}"
    }



    $process = New-Object System.Diagnostics.Process
    $process.StartInfo.FileName = $pscpPath
    $process.StartInfo.Arguments = $arguments
    $process.StartInfo.RedirectStandardOutput = $true
    $process.StartInfo.FileName
    $process.StartInfo.RedirectStandardError = $true
    $process.StartInfo.UseShellExecute = $false
    $process.StartInfo.CreateNoWindow = $true

    $process.Start() | Out-Null

    $reader = $process.StandardOutput
    $errorReader = $process.StandardError
    $richTextBox.Text = ""
    $percent = 0
    $progressBar.Value = $percent
    #$progressBar.PerformStep()

    while (!$process.HasExited) {
        Start-Sleep -Milliseconds 100
        #if($reader.ReadToEnd() -eq "") {
            #$richTextBox.Text=""
        #}
        #$progressBar.PerformStep()
        #Start-Sleep -Milliseconds 1100
        #$richTextBox.Text = $reader.ReadLine()
        $richTextBox.Text = $reader.ReadLine()
        #$progressBar.Step += 10

        if ($richTextBox.Text -match "\b(\d+)%") {
            $percent = $matches[1]
            #Write-Host "Found: $percent at String: $rl"
        }
        Start-Sleep -Milliseconds 200
        $progressBar.Value = $percent

        #$richTextBox.AppendText($reader.ReadToEnd())
    }

    #$richTextBox.Text = $reader.ReadToEnd()

    $progressBar.PerformStep()

    $richTextBox.AppendText($reader.ReadToEnd())
    $richTextBox.AppendText($errorReader.ReadToEnd())
    

})

Start-Sleep -Milliseconds 200
$progressBar.Style = "Blocks"
$buttonUpload.Text = "Start Upload"

$form.Controls.Add($buttonUpload)

$form.ShowDialog()

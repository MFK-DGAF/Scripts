$String = 'L0gSh@r3'
ConvertFrom-SecureString -SecureString (ConvertTo-SecureString -String $String -AsPlainText -Force)
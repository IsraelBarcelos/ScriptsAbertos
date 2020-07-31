function Troca-Texto {
    Param([string]$stringAntiga, [string] $stringNova, [string] $linha)
    return $linha -replace $stringAntiga,$stringNova
}




$Text = Get-Content -Path D:\panicat.txt
#Transformando as linhas do arquivo em um array 
$Text.GetType() | Format-Table -AutoSize | Out-null
#Listando as linhas do arquivo
foreach ($element in $Text) 
{ 
    $matches = ([regex]'(INICIO\s\d\d\/\d\d\/\d\d\d\d\s\d\d:\d\d)|(FIM\s\d\d\/\d\d\/\d\d\d\d\s\d\d:\d\d)|Z([^\s])+').Matches($element); 
    <#$matches[0].Value; # Servidor
    $matches[1].Value; # INICIO
    $matches[2].Value; # FIM
    #>

    #$element.substring($element.IndexOf($matches[0].Value),$matches[0].Value.Length)
    #Significa: na linha, pegar o nome do servidor e pegar desde o seu primeiro indice até o seu ultimo,
    # dessa maneira a string só troca na sua própria linha
    
    if($matches[0].Value -ne $null -and $element.substring($element.IndexOf($matches[0].Value),$matches[0].Value.Length) -eq $matches[0].Value) { #ler oq eu quero e dar replace trocando a lane inteira por a lane inteira, trocados os parametros
        $digitado = ""; #varglobal para poder acessar o que foi digitado e analisar fora do do while
        $digitado2 = "";
        $digitouDataDeInicio = $false;
        

        do{ #le apenas formatos certos de dados

            $digitado = read-host "Digite a data e o horário do INICIO do job do servidor "$matches[0]",digite ""a"" para aguardando inicio, ""r"" para reprocessando apos erro, ""h"" para hold,""d"" para atrasado, ""e"" para informar que esta executando, ""p"" para problema : erro na execucao"
            $regexteste = ([regex]'(\d\d\/\d\d\/\d\d\d\d\s\d\d:\d\d)|^[arhepd]$').Matches($digitado);
   
        }while($regexteste[0] -eq $null)

        if($digitado.Length -eq 16) { #se 12/12/1234 12:34
            $digitouDataDeInicio = $true;
            $desejoTrocar = $matches[1].Value.substring(7,16);
            $textoASerTrocado = $digitado
            $linhaDesejada = $element -replace $desejoTrocar,$textoASerTrocado
            $Text = $Text -replace $element,$linhaDesejada
            $element = $linhaDesejada # Atualiza a linha, para que nas proximas alterações ela mantenha o valor correto
           
            do{ #le apenas formatos certos de dados do fim do job

                $digitado2 = read-host "Digite a data e o horário de FIM do job do servidor "$matches[0]",digite ""r"" para reprocessando apos erro, ""h"" para hold,""d"" para atrasado, ""e"" para informar que esta executando"
                $regexteste2 = ([regex]'(\d\d\/\d\d\/\d\d\d\d\s\d\d:\d\d)|^[rhed]$').Matches($digitado2);
   
            }while($regexteste2[0] -eq $null)


            if($digitado2.Length -eq 16) {
                               
                $desejoTrocar = $matches[2].Value.substring(4,16);
                $linhaDesejada = Troca-Texto -stringAntiga $matches[2].Value.substring(4,16) -stringNova $digitado2 -linha $element
                
                $textoRealocado = ([regex]'^([^\s]+)').Matches($linhaDesejada);
                $textoASerTrocado = "✅"
                $linhaDesejada2 = Troca-Texto -stringAntiga $textoRealocado -stringNova $textoASerTrocado -linha $linhaDesejada
             
                $Text = $Text  -replace $element,$linhaDesejada2
                $element = $linhaDesejada2;

            }


        }

        switch($digitado) {

            "a" {
                $textoRealocado = ([regex]'^([^\s]+)').Matches($element); # Pego o primeiro elemento da linha antes do espaço
                $textoASerTrocado = "⏸" #Troco por este elemento
                # $linhaDesejada = $element -replace $textoRealocado,$textoASerTrocado
                $linhaDesejada = Troca-Texto -stringAntiga $textoRealocado -stringNova $textoASerTrocado -linha $element # Crio a linha com as trocas realizadas


                $posicaoInicio = $linhaDesejada.IndexOf($matches[1].value) #remove do inicio pra frente
                $posicaoFim = $linhaDesejada.Length
                $substringASerRemovida = $linhaDesejada.Substring($posicaoInicio,$posicaoFim - $posicaoInicio)
                $linhaDesejada2 = Troca-Texto -stringAntiga $substringASerRemovida -stringNova "" -linha $linhaDesejada
                $Text = $Text -replace $element, $linhaDesejada2
                $element = $linhaDesejada2;
                $digitouDataDeInicio = $true;
            } #Para o futuro : Podemos passar as 2 ultimas linhas como apenas 2x ao inves de repetir durante todo o codigo

            # caso de reprocessando
            "r" {
                $textoRealocado = ([regex]'^([^\s]+)').Matches($element);   
                $textoASerTrocado = "🔂"
                $linhaDesejada = Troca-Texto -stringAntiga $textoRealocado -stringNova $textoASerTrocado -linha $element
              
                $posicaoInicio = $linhaDesejada.IndexOf($matches[2].value) # remove do fim para frente
                $posicaoFim = $linhaDesejada.Length
                $substringASerRemovida = $linhaDesejada.Substring($posicaoInicio,$posicaoFim - $posicaoInicio)
                #$linhaDesejada2 = $linhaDesejada -replace $substringASerRemovida,""   --se der problema comentar a de baixo
                $linhaDesejada2 = Troca-Texto -stringAntiga $substringASerRemovida -stringNova "" -linha $linhaDesejada
                $Text = $Text -replace $element, $linhaDesejada2
                $element = $linhaDesejada2;
            }
            # caso de hold
            "h" { #tem problema
                $textoRealocado = ([regex]'^([^\s]+)').Matches($element);
                $textoASerTrocado = "⏹"
                $linhaDesejada = $element -replace $textoRealocado,$textoASerTrocado
      
                $posicaoInicio = $linhaDesejada.IndexOf($matches[2].value) # remove do fim para frente
                $matches[2].value
                $posicaoFim = $linhaDesejada.Length
                $substringASerRemovida = $linhaDesejada.Substring($posicaoInicio,$posicaoFim - $posicaoInicio)
                $linhaDesejada2 = $linhaDesejada -replace $substringASerRemovida,""
                $Text = $Text -replace $element, $linhaDesejada2
                $element = $linhaDesejada2;
                
            }
            # caso de atrasado
            "d" {
                $textoRealocado = ([regex]'^([^\s]+)').Matches($element);
                $textoASerTrocado = "ℹ"
                $linhaDesejada = $element -replace $textoRealocado,$textoASerTrocado

                $posicaoInicio = $linhaDesejada.IndexOf($matches[1].value) #remove do inicio pra frente
                $posicaoFim = $linhaDesejada.Length
                $substringASerRemovida = $linhaDesejada.Substring($posicaoInicio,$posicaoFim - $posicaoInicio)
                $linhaDesejada2 = $linhaDesejada -replace $substringASerRemovida,""
                $Text = $Text -replace $element, $linhaDesejada2
                $element = $linhaDesejada2;
                $digitouDataDeInicio = $true;   
            }
            # caso de execução
            "e" {
                $textoRealocado = ([regex]'^([^\s]+)').Matches($element);
                $textoASerTrocado = "▶️"
                $linhaDesejada = $element -replace $textoRealocado,$textoASerTrocado
                
                $posicaoInicio = $linhaDesejada.IndexOf($matches[2].value) # remove do fim para frente
                $posicaoFim = $linhaDesejada.Length
                $substringASerRemovida = $linhaDesejada.Substring($posicaoInicio,$posicaoFim - $posicaoInicio)
                $linhaDesejada2 = $linhaDesejada -replace $substringASerRemovida,""
                $Text = $Text -replace $element, $linhaDesejada2
                $element = $linhaDesejada2;
                
            }
            # caso de problemas
            "p" {
                $textoRealocado = ([regex]'^([^\s]+)').Matches($element);
                $textoASerTrocado = "❌"
                $linhaDesejada = $element -replace $textoRealocado,$textoASerTrocado

                $posicaoInicio = $linhaDesejada.IndexOf($matches[1].value)
                $posicaoFim = $linhaDesejada.Length
                $substringASerRemovida = $linhaDesejada.Substring($posicaoInicio,$posicaoFim - $posicaoInicio)
                $linhaDesejada2 = $linhaDesejada -replace $substringASerRemovida,""
                $Text = $Text -replace $element, $linhaDesejada2
                $element = $linhaDesejada2;
                $digitouDataDeInicio = $true;

            }

        }


        switch($digitado2) {

            "a" {
                $textoRealocado = ([regex]'^([^\s]+)').Matches($element); # Pego o primeiro elemento da linha antes do espaço
                $textoASerTrocado = "⏸" #Troco por este elemento
                $linhaDesejada = $element -replace $textoRealocado,$textoASerTrocado # Crio a linha com as trocas realizadas

                $posicaoInicio = $linhaDesejada.IndexOf($matches[1].value) #remove do inicio pra frente
                $posicaoFim = $linhaDesejada.Length
                $substringASerRemovida = $linhaDesejada.Substring($posicaoInicio,$posicaoFim - $posicaoInicio)
                $linhaDesejada2 = $linhaDesejada -replace $substringASerRemovida,""
                $Text = $Text -replace $element, $linhaDesejada2
                $element = $linhaDesejada2;
                $digitouDataDeInicio = $true;
            } #Para o futuro : Podemos passar as 2 ultimas linhas como apenas 2x ao inves de repetir durante todo o codigo

            # caso de reprocessando
            "r" {
                $textoRealocado = ([regex]'^([^\s]+)').Matches($element);   
                $textoASerTrocado = "🔂"
                $linhaDesejada = Troca-Texto -stringAntiga $textoRealocado -stringNova $textoASerTrocado -linha $element
              
                $posicaoInicio = $linhaDesejada.IndexOf($matches[2].value) # remove do fim para frente
                $posicaoFim = $linhaDesejada.Length
                $substringASerRemovida = $linhaDesejada.Substring($posicaoInicio,$posicaoFim - $posicaoInicio)
                #$linhaDesejada2 = $linhaDesejada -replace $substringASerRemovida,""   --se der problema comentar a de baixo
                $linhaDesejada2 = Troca-Texto -stringAntiga $substringASerRemovida -stringNova "" -linha $linhaDesejada

                $Text = $Text -replace $element, $linhaDesejada2
                $element = $linhaDesejada2;
            }
            # caso de hold
            "h" {
                $textoRealocado = ([regex]'^([^\s]+)').Matches($element);
                $textoASerTrocado = "⏹"
                $linhaDesejada = $element -replace $textoRealocado,$textoASerTrocado
      
                $posicaoInicio = $linhaDesejada.IndexOf($matches[2].value) # remove do fim para frente
         
                $posicaoFim = $linhaDesejada.Length
                $substringASerRemovida = $linhaDesejada.Substring($posicaoInicio,$posicaoFim - $posicaoInicio)
                $linhaDesejada2 = $linhaDesejada -replace $substringASerRemovida,""
                $Text = $Text -replace $element, $linhaDesejada2
                $element = $linhaDesejada2;
            }
            # caso de atrasado
            "d" {
                $textoRealocado = ([regex]'^([^\s]+)').Matches($element);
                $textoASerTrocado = "ℹ"
                $linhaDesejada = $element -replace $textoRealocado,$textoASerTrocado

                $posicaoInicio = $linhaDesejada.IndexOf($matches[1].value) #remove do inicio pra frente
                $posicaoFim = $linhaDesejada.Length
                $substringASerRemovida = $linhaDesejada.Substring($posicaoInicio,$posicaoFim - $posicaoInicio)
                $linhaDesejada2 = $linhaDesejada -replace $substringASerRemovida,""
                $Text = $Text -replace $element, $linhaDesejada2
                $element = $linhaDesejada2;
                $digitouDataDeInicio = $true;   
            }
            # caso de execução
            "e" {
                $textoRealocado = ([regex]'^([^\s]+)').Matches($element);
                $textoASerTrocado = "▶️"
                $linhaDesejada = $element -replace $textoRealocado,$textoASerTrocado
                

                $posicaoInicio = $linhaDesejada.IndexOf($matches[2].value) # remove do fim para frente
                $posicaoFim = $linhaDesejada.Length
                $substringASerRemovida = $linhaDesejada.Substring($posicaoInicio,$posicaoFim - $posicaoInicio)
                $linhaDesejada2 = $linhaDesejada -replace $substringASerRemovida,""
                $Text = $Text -replace $element, $linhaDesejada2
                $element = $linhaDesejada2;
            }
            # caso de problemas
            "p" {
                $textoRealocado = ([regex]'^([^\s]+)').Matches($element);
                $textoASerTrocado = "❌"
                $linhaDesejada = $element -replace $textoRealocado,$textoASerTrocado

                $posicaoInicio = $linhaDesejada.IndexOf($matches[1].value)
                $posicaoFim = $linhaDesejada.Length
                $substringASerRemovida = $linhaDesejada.Substring($posicaoInicio,$posicaoFim - $posicaoInicio)
                $linhaDesejada2 = $linhaDesejada -replace $substringASerRemovida,""
                $Text = $Text -replace $element, $linhaDesejada2
                $element = $linhaDesejada2;
                $digitouDataDeInicio = $true;

            }

        }

        if(-not $digitouDataDeInicio) {
            do{ #le apenas formatos certos de dados

            $digitado3 = read-host "Digite a data e o horário do INICIO do job do servidor "$matches[0]""
            $regexteste = ([regex]'(\d\d\/\d\d\/\d\d\d\d\s\d\d:\d\d)').Matches($digitado3);
   
            }while($regexteste[0] -eq $null)

            if($digitado3.Length -eq 16) { #se 12/12/1234 12:34
                $digitadoInicio = $true;
                $desejoTrocar = $matches[1].Value.substring(7,16);
                $textoASerTrocado = $digitado3
                $linhaDesejada = $element -replace $desejoTrocar,$textoASerTrocado
                $Text = $Text -replace $element,$linhaDesejada
                $element = $linhaDesejada
            }
            

        }
        

    }
        
        
}
$Text | Set-Content -Path D:\automacao.txt -Encoding UTF8 | Out-Null

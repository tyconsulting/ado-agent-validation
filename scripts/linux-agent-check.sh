#!/bin/bash

# bash "safe" options
#set -eu

#variables
check_passed=true
RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
urls=()

urls+=("https://kubereboot.github.io/charts/")
urls+=("https://kedacore.github.io/charts/")
urls+=("https://api.github.com/")
urls+=("https://objects.githubusercontent.com/")
urls+=("https://dseasb33srnrn.cloudfront.net/")
urls+=("https://production.cloudflare.docker.com/")

echo ""
echo -e "${GREEN}==================================${NC}"
echo ""
echo -e "${GREEN}Checking ADO agent instance $AGENT_NAME on computer $AGENT_MACHINENAME.${NC}"
echo ""
echo -e "${GREEN}ADO Agent Instance Name: $AGENT_NAME${NC}"
echo -e "${GREEN}ADO Agent Computer Name: $AGENT_MACHINENAME${NC}"
echo -e "${GREEN}Current User: $(whoami)${NC}"
echo ""
echo -e "${GREEN}Linux version: $(cat /etc/*-release)${NC}"
echo ""
echo -e "${GREEN}==================================${NC}"
echo ""

echo -e "${GREEN}Checking locations for required tools${NC}"
echo ""
azure_cli_location=$(which az 2>/dev/null)
pwsh_location=$(which pwsh 2>/dev/null)
bicep_location=$(which bicep 2>/dev/null)
jq_location=$(which jq 2>/dev/null)
python3_location=$(which python3 2>/dev/null)
pip3_location=$(which pip3 2>/dev/null)
kubectl_location=$(which kubectl 2>/dev/null)
kubelogin_location=$(which kubelogin 2>/dev/null)
podman_location=$(which podman 2>/dev/null)
echo ""
echo "=================================="
echo ""

#Python and pip3
echo -e "${GREEN}Checking Python3${NC}"
if [ -z "$python3_location" ]; then
  echo -e "${RED}Python3 not found${NC}"
  check_passed=false
else
  echo "Python3 Location: $python3_location"
  echo "Python3 Version: $(python3 --version)"
fi
echo ""
echo "=================================="
echo ""

echo -e "${GREEN}Checking pip3${NC}"
if [ -z "$pip3_location" ]; then
  echo -e "${RED}pip3 not found${NC}"
  check_passed=false
else
  echo "pip3 Location: $pip3_location"
  echo "pip3 Version: $(pip3 --version)"
fi
echo ""
echo "=================================="
echo ""

#Azure CLI
echo -e "${GREEN}Checking Azure CLI${NC}"
if [ -z "$azure_cli_location" ]; then
  echo -e "${RED}Azure CLI not found${NC}"
  check_passed=false
else
  echo "Azure CLI Location: $azure_cli_location"
  echo "Azure CLI Version: $(az --version)"
  echo ""
  # check if bicep extension is installed
  az_bicep_version=$(az bicep version)
  if [ -z "$az_bicep_version" ]; then
    echo "Azure CLI Bicep Extension Version: $az_bicep_version"
    echo -e "${RED}Azure CLI Bicep Extension not found${NC}"
    check_passed=false
  else
    echo "Azure CLI Bicep Extension Version: $az_bicep_version"
  fi
  echo ""
  echo "List of installed Azure CLI Extensions:"
  az extension list --output table
  echo ""
  az_cli_installed_ext_names=$(az extension list --output tsv --query "[].name")

  # check k8s-configuration extension
  if [[ $az_cli_installed_ext_names == *"k8s-configuration"* ]]; then
    echo "k8s-configuration Extension found"
  else
    echo -e "${RED}k8s-configuration Extension not found"
    check_passed=false
  fi
  echo ""

  # check k8sconfiguration extension
  if [[ $az_cli_installed_ext_names == *"k8sconfiguration"* ]]; then
    echo "k8sconfiguration Extension found"
  else
    echo -e "${RED}k8sconfiguration Extension not found${NC}"
    check_passed=false
  fi
  echo ""

  # check connectedk8s extension
  if [[ $az_cli_installed_ext_names == *"connectedk8s"* ]]; then
    echo "connectedk8s Extension found"
  else
    echo -e "${RED}connectedk8s Extension not found${NC}"
    check_passed=false
  fi
  echo ""

  # check k8s-extension extension
  if [[ $az_cli_installed_ext_names == *"k8s-extension"* ]]; then
    echo "k8s-extension Extension found"
  else
    echo -e "${RED}k8s-extension Extension not found${NC}"
    check_passed=false
  fi
  echo ""
fi

echo ""
echo "=================================="
echo ""

#Podman
echo -e "${GREEN}Checking podman${NC}"
if [ -z "$podman_location" ]; then
  echo -e "${RED}podman not found${NC}"
  check_passed=false
else
  echo "podman Location: $podman_location"
  echo "podman Version: $(podman version)"
fi
echo ""
echo "=================================="
echo ""

#Kubectl and Kubelogin
echo -e "${GREEN}Checking kubctl${NC}"
if [ -z "$kubectl_location" ]; then
  echo -e "${RED}kubectl not found${NC}"
  check_passed=false
else
  echo "kubectl Location: $kubectl_location"
  echo "kubectl Version: $(kubectl version --output=json 2>/dev/null)"
fi
echo ""
echo "=================================="
echo ""

echo -e "${GREEN}Checking kubelogin${NC}"
if [ -z "$kubelogin_location" ]; then
  echo -e "${RED}kubelogin not found${NC}"
  check_passed=false
else
  echo "kubelogin Location: $kubelogin_location"
  echo "kubelogin Version: $(kubelogin --version)"
fi
echo ""
echo "=================================="
echo ""

#Bicep
echo -e "${GREEN}Checking Azure Bicep (Standalone)${NC}"
if [ -z "$bicep_location" ]; then
  echo -e "${RED}Azure Bicep (Standalone) not found${NC}"
  check_passed=false
else
  echo "Azure Bicep (Standalone) Location: $bicep_location"
  echo "Azure Bicep (Standalone) Version: $(bicep --version)"
fi
echo ""
echo "=================================="
echo ""

#PowerShell
echo -e "${GREEN}Checking PowerShell${NC}"
if [ -z "$pwsh_location" ]; then
  echo -e "${RED}PowerShell not found${NC}"
  check_passed=false
else
  echo "PowerShell Location: $pwsh_location"
  echo "PowerShell Version: $(pwsh --version)"
  echo ""
  echo -e "${GREEN}checking PowerShell modules"
  echo "looking for Az module"
  az_module_version=$(pwsh -c "Get-InstalledModule -Name Az -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Version")
  if [ -z "$az_module_version" ]; then
    echo -e "${RED}Az module not found${NC}"
    check_passed=false
  else
    echo "Az module Version: $az_module_version"
  fi
  echo ""

  echo "looking for Az.ResourceGraph module"
  az_resource_graph_module_version=$(pwsh -c "Get-InstalledModule -Name Az.ResourceGraph -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Version")
  if [ -z "$az_resource_graph_module_version" ]; then
    echo -e "${RED}Az.ResourceGraph module not found${NC}"
    check_passed=false
  else
    echo "Az.ResourceGraph module Version: $az_resource_graph_module_version"
  fi
  echo ""

  echo "looking for Microsoft.Graph module"
  microsoft_graph_module_version=$(pwsh -c "Get-InstalledModule -Name Microsoft.Graph -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Version")
  if [ -z "$microsoft_graph_module_version" ]; then
    echo -e "${RED}Microsoft.Graph module not found${NC}"
    check_passed=false
  else
    echo "Microsoft.Graph module Version: $microsoft_graph_module_version"
  fi
  echo ""

  echo "looking for Pester module"
  pester_module_version=$(pwsh -c "Get-InstalledModule -Name Pester -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Version")
  if [ -z "$pester_module_version" ]; then
    echo -e "${RED}Pester module not found${NC}"
    check_passed=false
  else
    echo "Pester module Version: $pester_module_version"
  fi
  echo ""

  echo "looking for PSRule module"
  psrule_module_version=$(pwsh -c "Get-InstalledModule -Name PSRule -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Version")
  if [ -z "$psrule_module_version" ]; then
    echo -e "${RED}PSRule module not found${NC}"
    check_passed=false
  else
    echo "PSRule module Version: $psrule_module_version"
  fi
  echo ""

  echo "looking for PSRule.Rules.Azure module"
  psrule_rules_azure_module_version=$(pwsh -c "Get-InstalledModule -Name PSRule.Rules.Azure -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Version")
  if [ -z "$psrule_rules_azure_module_version" ]; then
    echo -e "${RED}PSRule.Rules.Azure module not found${NC}"
    check_passed=false
  else
    echo "PSRule.Rules.Azure module Version: $psrule_rules_azure_module_version"
  fi
  echo ""

  echo "looking for powershell-yaml module"
  powershell_yaml_module_version=$(pwsh -c "Get-InstalledModule -Name powershell-yaml -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Version")
  if [ -z "$powershell_yaml_module_version" ]; then
    echo -e "${RED}powershell-yaml module not found${NC}"
    check_passed=false
  else
    echo "powershell-yaml module Version: $powershell_yaml_module_version"
  fi
fi
echo ""
echo "=================================="
echo ""

#jq
echo -e "${GREEN}Checking jq${NC}"
if [ -z "$jq_location" ]; then
  echo -e "${RED}jq not found${NC}"
  check_passed=false
else
  echo "jq Location: $jq_location"
  echo "jq Version: $(jq --version)"
fi
echo ""
echo "=================================="
echo ""

#URL check
echo -e "${GREEN}Checking URLs${NC}"
echo ""
for url in "${urls[@]}"; do
  echo "Checking $url"
  response=$(curl --head --write-out '%{http_code}' --silent --output /dev/null "$url")
  if (($response >= 200 && $response <= 299)); then
    echo -e "${GREEN}URL $url is reachable. HTTP response code is $response.${NC}"
  else
    if (($response >= 400 && $response <= 499)); then
      echo -e "${YELLOW}URL $url did not return a successful response code. However it may still be reachable. HTTP response code is $response.${NC}"
    else
      echo -e "${RED}URL $url is not reachable. HTTP response code is $response.${NC}"
      check_passed=false
    fi
  fi
  echo ""
done
#Process end result
if [ $check_passed == true ]; then
  echo -e "${GREEN}All checks passed${NC}"
  exit
else
  echo -e "${RED}One or more checks failed${NC}"
  exit 1
fi

# PewPew Snippets generator
# Copyright (c) 2023 PPMS Team & contributors.
# This project is licensed under MIT license.

$raw_docs = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/pewpewlive/ppl-utils/master/docs/raw_documentation.js").Content

# Strip `var documentation = ` to make it compatible with JSON
$raw_docs = $raw_docs.Replace("var documentation = ", "")

$docs_obj = ConvertFrom-Json $raw_docs -AsHashtable

$pewpew = $docs_obj[0]
$fmath = $docs_obj[1]

function Out-Enums {
  param (
    $table_name,
    $enums
  )
  
  $enums_obj = [ordered]@{}
  foreach ($enum in $enums) {
    foreach ($value in $enum.values) {
      $enums_obj[("{0}_{1}" -f $enum.name, $value)] = [ordered]@{}
      $enums_obj[("{0}_{1}" -f $enum.name, $value)]["prefix"] = ("{0}.{1}.{2}" -f $table_name, $enum.name, $value)
      $enums_obj[("{0}_{1}" -f $enum.name, $value)]["body"] = ("{0}.{1}.{2}" -f $table_name, $enum.name, $value)
    }
  }

  return $enums_obj
}

function Out-Functions {
  param (
    $table_name,
    $funcs
  )
  
  $functions_obj = [ordered]@{}

  foreach ($func in $funcs) {
    $func_args = ""
    $functions_obj[$func.func_name] = [ordered]@{}
    $functions_obj[$func.func_name]["prefix"] = ("{0}.{1}" -f $table_name, $func.func_name)
    for ($i = 0; $i -lt $func.parameters.Count; $i++) {
      if ($i -eq $func.parameters.Count - 1) {
        $func_args += "`${" + ($i + 1) + ":" + $func.parameters[$i].name + "}"
      } else {
        $func_args += "`${" + ($i + 1) + ":" + $func.parameters[$i].name + "}, "
      }
    }
    $functions_obj[$func.func_name]["body"] = ("{0}.{1}({2})" -f $table_name, $func.func_name, $func_args)
    $functions_obj[$func.func_name]["description"] = $func.comment
  }

  return $functions_obj
}

$pewpew_enums = ConvertTo-Json (Out-Enums $pewpew.name $pewpew.enums)
$pewpew_functions = ConvertTo-Json (Out-Functions $pewpew.name $pewpew.functions)
$fmath_functions = ConvertTo-Json (Out-Functions $fmath.name $fmath.functions)

"// Auto-generated PewPew enums from ppl-utils (https://github.com/pewpewlive/ppl-utils)`n$pewpew_enums" | Out-File -Encoding utf8 -FilePath "./snippets/generated/pewpew-enums.code-snippets"
"// Auto-generated PewPew funcs from ppl-utils (https://github.com/pewpewlive/ppl-utils)`n$pewpew_functions" | Out-File -Encoding utf8 -FilePath "./snippets/generated/pewpew-funcs.code-snippets"
"// Auto-generated Fmath funcs from ppl-utils (https://github.com/pewpewlive/ppl-utils)`n$fmath_functions" | Out-File -Encoding utf8 -FilePath "./snippets/generated/fmath-funcs.code-snippets"
local tinyyaml_path = assert(
  kpse.find_file("tinyyaml.lua", "texmfscripts") or kpse.find_file("tinyyaml.lua", "lua"),
  "tinyyaml.lua not found"
)
local tinyyaml = assert(loadfile(tinyyaml_path))()

local function read_file(path)
  local file = assert(io.open(path, "r"))
  local contents = file:read("*a")
  file:close()
  return contents
end

local function tex_escape(value)
  local replacements = {
    ["\\"] = "\\textbackslash{}",
    ["{"] = "\\{",
    ["}"] = "\\}",
    ["#"] = "\\#",
    ["$"] = "\\$",
    ["%"] = "\\%",
    ["&"] = "\\&",
    ["_"] = "\\_",
    ["^"] = "\\textasciicircum{}",
    ["~"] = "\\textasciitilde{}",
  }

  return (value:gsub("[\\{}#$%%&_^~]", replacements))
end

local function define_secret(key, value)
  tex.sprint(string.format(
    "\\expandafter\\def\\csname secret@%s\\endcsname{%s}",
    key,
    tex_escape(value)
  ))
end

local secrets_path = os.getenv("RESUME_SECRETS_FILE") or "secrets.enc.yaml"
local field = secrets_path == "secrets.enc.yaml" and "default" or "data"
local yaml_source = read_file(secrets_path)

local secrets = tinyyaml.parse(yaml_source)
for key, payload in pairs(secrets) do
  if key ~= "sops" and type(payload) == "table" then
    local value = payload[field]
    if type(value) ~= "string" then
      error(string.format("Secret '%s.%s' must be a string", key, field))
    end
    define_secret(key, value)
  end
end

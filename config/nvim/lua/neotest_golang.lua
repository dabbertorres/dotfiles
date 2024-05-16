local Path = require("plenary.path")
local lib = require("neotest.lib")
local notifications = require("notifications")

-- returns current (sub-)package, root directory (containing go.mod)
local function gomod_info(file_path)
    local mod_cmd = io.popen("go env GOMOD", "r")
    if mod_cmd == nil then return nil, nil end

    local module = mod_cmd:read("l")
    local ok, _, _ = mod_cmd:close()
    if not ok or module == "/dev/null" or module == "NUL" then
        return nil, nil
    end

    local pkg_cmd = io.popen("go mod edit -json", "r")
    if pkg_cmd == nil then return nil, nil end

    local mod_info = pkg_cmd:read("a")
    ok, _, _ = pkg_cmd:close()
    if not ok then return nil, nil end

    local pkg = vim.json.decode(mod_info)["Package"]
    local root = Path.new(module):parent()
    local current_path = Path.new(file_path)

    if not current_path:is_dir() then
        current_path = current_path:parent()
    end

    local pkg_rel = current_path:make_relative(root)
    if pkg_rel ~= "." then
        pkg = pkg .. "/" .. pkg_rel
    end

    return pkg, tostring(root)
end

local function update_test(test, event)
    local action = event["Action"]
    if action == "pass" then
        test.status = "passed"
    elseif action == "fail" then
        test.status = "failed"
    elseif action == "skip" then
        test.status = "skipped"
    elseif action == "output" then
        local output = vim.trim(event["Output"])
        if not vim.startswith(output, "---")
            and not vim.startswith(output, "===")
            and not vim.startswith(output, "PASS")
            and not vim.startswith(output, "ok")
        then
            if test.short == nil then
                test.short = output
            else
                test.short = test.short .. "\n" .. output
            end
        end
    end

    return test
end

local M = {
    name = "Go",
    root = lib.files.match_root_pattern("go.mod"),
}

function M.is_test_file(file_path)
    return string.match(file_path, ".+_test.go$") ~= nil
end

function M.discover_positions(file_path)
    -- TODO namespace should be the full package name
    local query = [[
(function_declaration
    name: (identifier) @test.name (#match? @test.name "^Test")
    parameters: (parameter_list
        (parameter_declaration
            name: (identifier) @testing_arg_name
            type: (pointer_type
                (qualified_type
                    package: (package_identifier) @package_name (#eq? @package_name "testing")
                    name: (type_identifier) @type_name (#eq? @type_name "T")
                )
            )
        )
    )
) @test.definition
]]

    local package, _ = gomod_info(file_path)

    local tree = lib.treesitter.parse_positions(file_path, query, {
        nested_tests = true,
        require_namespaces = false,
    })

    for _, node in tree:iter_nodes() do
        local pos = node:data()
        if pos.type == "test" then
            pos.name = package .. "/" .. pos.name
        end
    end

    return tree
end

-- local test_invocations = 0

function M.build_spec(args)
    local position = args.tree:data()
    local command = { "go", "test", "-json" }
    local cwd = Path.new(position.path)

    -- test_invocations = test_invocations + 1
    -- local notification_data = notifications.get("neotest", "Go" .. test_invocations)

    -- notifications.init_spinner("neotest", "Go", notification_data, {
    --     title = notifications.format_title("Test " .. position.name, "Go"),
    --     timeout = false,
    --     hide_from_history = false,
    -- })
    -- notification_data = vim.notify("Building...")
    vim.notify("Building...", vim.log.levels.INFO, {
        title = "Test: Go",
    })

    if position.type ~= "dir" then
        cwd = cwd:parent()
    end

    if position.type == "test" then
        table.insert(command, "-run=^" .. position.name .. "(/.+)?$")
    end

    if args.extra_args then
        command = vim.list_extend(command, args.extra_args)
    end

    table.insert(command, "./...")

    return {
        command = command,
        cwd = tostring(cwd),
    }
end

function M.results(spec, result, tree)
    if result.code == 0 then
        vim.notify("Complete", vim.log.levels.INFO, {
            title = "Test: Go",
        })
    else
        vim.notify("Failure", vim.log.levels.ERROR, {
            title = "Test: Go",
        })
    end

    local test_results = {}

    for line in io.lines(result.output, "l") do
        print(line)
        local event = vim.json.decode(line)

        local test_func = event["Test"]
        if test_func ~= nil then
            local name = event["Package"] .. "/" .. test_func

            local test = test_results[name]
            if test == nil then
                test = {}
            end

            print(name)
            test_results[name] = update_test(test, event)
        end
    end

    print(vim.inspect(test_results))

    return test_results
end

return M

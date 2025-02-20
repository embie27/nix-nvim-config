local in_mathzone = function()
  local has_treesitter, ts = pcall(require, "vim.treesitter")
  local _, query = pcall(require, "vim.treesitter.query")

  local MATH_ENVIRONMENTS = {
    displaymath = true,
    eqnarray = true,
    equation = true,
    math = true,
    array = true,
  }
  local MATH_NODES = {
    displayed_equation = true,
    inline_formula = true,
    math_environment = true,
  }

  local function get_node_at_cursor()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_range = { cursor[1] - 1, cursor[2] }
    local buf = vim.api.nvim_get_current_buf()
    local ok, parser = pcall(ts.get_parser, buf, "latex")
    if not ok or not parser then
      return
    end
    local root_tree = parser:parse()[1]
    local root = root_tree and root_tree:root()

    if not root then
      return
    end

    return root:named_descendant_for_range(cursor_range[1], cursor_range[2], cursor_range[1], cursor_range[2])
  end

  if has_treesitter then
    local buf = vim.api.nvim_get_current_buf()
    local node = get_node_at_cursor()
    while node do
      if MATH_NODES[node:type()] then
        return true
      end
      if node:type() == "environment" then
        local begin = node:child(0)
        local names = begin and begin:field "name"

        if names and names[1] and MATH_ENVIRONMENTS[query.get_node_text(names[1], buf):gsub("[%s*]", "")] then
          return true
        end
      end
      node = node:parent()
    end
    return false
  end
end

local ls = require("luasnip")
local s = ls.extend_decorator.apply(ls.snippet, { condition = in_mathzone })

local snippets = {}

local auto_snippets = {
  s({ trig = "([^%s]*[^%)])//", regTrig = true }, {
    d(1, function(_, snip)
      local selected = snip.env.TM_SELECTED_TEXT[1]
      if selected then
        return sn(nil, { t "\\frac{", t(selected), t "}{", i(1), t "}" })
      end
      if snip.captures[1] == " " then
        return sn(nil, { t "\\frac{", i(1), t "}{", i(2), t "}" })
      end
      return sn(nil, { t "\\frac{", t(snip.captures[1]), t "}{", i(1), t "}" })
    end),
    i(0),
  }),
  s({ trig = "(.*%))//", regTrig = true }, {
    d(1, function(_, snip)
      local capture = snip.captures[1]
      local level = 0
      local pos = #capture
      while pos > 1 do
        local char = capture:sub(pos, pos)
        if char == ")" then
          level = level + 1
        elseif char == "(" then
          level = level - 1
        end
        if level == 0 then
          break
        end
        pos = pos - 1
      end
      return sn(nil, {
        t(capture:sub(1, pos - 1)),
        t "\\frac{",
        t(capture:sub(pos + 1, #capture - 1)),
        t "}{",
        i(1),
        t "}",
        i(0),
      })
    end),
  }),
  s("!=", { t "\\neq ", i(0) }),
  s("==", { t "&= ", i(0) }),
  s("ooo", { t "\\infty{", i(0) }),
  s(">=", { t "\\geq", i(0) }),
  s("<=", { t "\\leq", i(0) }),
  s("mcal", { t "\\mathcal{", i(1), t "}", i(0) }),
  s("mfrak", { t "\\mathfrak{", i(1), t "}", i(0) }),
  s("msrc", { t "\\mathsrc{", i(1), t "}", i(0) }),
  s("lll", { t "\\ell", i(0) }),
  s("xx", { t "\\times", i(0) }),
  s("<->", { t "\\leftrightarrow", i(0) }),
  s("->", { t "\\to", i(0) }),
  s("!>", { t "\\mapsto", i(0) }),
  s("\\\\\\", { t "\\setminus ", i(0) }),
  s("set", { t "\\{", i(1), t "\\}", i(0) }),
  s("cc", { t "\\subseteq", i(0) }),
  s("nin", { t "\\notin ", i(0) }),
  s("inn", { t "\\in ", i(0) }),
  s("uu", { t "\\cup ", i(0) }),
  s("UU", { t "\\cap ", i(0) }),
  s("00", { t "\\emptyset", i(0) }),
  -- s("//", { t "\\frac{", i(1), t "}{", i(2), t "}" }),
  s("=>", t "\\implies"),
  s({ trig = "inv", wordTrig = false }, { t "^{-1}", i(0) }),
  s({ trig = "star", wordTrig = false }, { t "^{*}", i(0) }),
  s({ trig = "^^", wordTrig = false }, { t "^{", i(1), t "}", i(0) }),
  s({ trig = "__", wordTrig = false }, { t "_{", i(1), t "}", i(0) }),
  s({ trig = "..." }, {
    t "\\ldots",
  }),
  s("||", { t "\\mid ", i(0) }),
}

local function balanced_matcher(line_to_cursor, trigger)
  -- look for match which ends at the cursor.
  -- put all results into a list, there might be many capture-groups.
  
  
  local find_res = { line_to_cursor:find(trigger .. "$") }

  if #find_res > 0 then
    -- find_res[1] is `from`, find_res[2] is `to` (which we already know
    -- anyway).
    local from = find_res[1]
    local new_from = #line_to_cursor+1

    -- find longest match with balanced brackets
    local stack = {}
    for i = #line_to_cursor, from, -1 do
      local char = line_to_cursor:sub(i, i)
      if char == '}' or char == ']' or char == ')' then
        table.insert(stack, char)
      elseif char == '{' or char == '[' or char == '(' then
        local top = stack[#stack]
        if (char == '{' and top == '}') or (char == '[' and top == ']') or (char == '(' and top == ')') then
          table.remove(stack)
        else
          break
        end
      end
      if #stack == 0 then
        new_from = i
      end
    end

    if new_from <= #line_to_cursor then
      find_res = { line_to_cursor:find(trigger .. "$", new_from) }
      from = find_res[1]
      if from == nil then
        return nil
      end
      -- if there is a match, determine matching string, and the
      -- capture-groups.
      local captures = {}
      local match = line_to_cursor:sub(from, #line_to_cursor)
      -- collect capture-groups.
      for i = 3, #find_res do
          captures[i - 2] = find_res[i]
      end
      return match, captures
    end
  end
  return nil
end

function balanced_engine(trigger)
  -- don't do any special work here, can't precompile lua-pattern.
  return balanced_matcher
end

for _, v in pairs { "bar", "hat", "vec", "tilde" } do
  auto_snippets[#auto_snippets + 1] = s(
    { trig = ("\\?%s"):format(v), regTrig = true },
    { t(("\\%s{"):format(v)), i(1), t "}", i(0) }
  )
  auto_snippets[#auto_snippets + 1] = s({ trig = "([^%s]*)" .. v, trigEngine = balanced_engine, priority = 1001 }, {
    d(1, function(_, snip, _)
      return sn(nil, { t(("\\%s{%s}"):format(v, snip.captures[1])) }, i(0))
    end),
  })
end

return snippets, auto_snippets

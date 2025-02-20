-- ls.add_snippets("tex", {
--     s({ trig = "math" }, { i(1), t " ", i(0) }, {
--         callbacks = {
--             [1] = {
--                 [events.leave] = function(node)
--                     local from_pos, to_pos = node.mark:pos_begin_end_raw()
--                     local lines = vim.api.nvim_buf_get_lines(0, from_pos[1], to_pos[1] + 1, false)
--                     local script = ([[!wolframscript -c "ToString@TeXForm[%s]"]]):format(node:get_text()[1])
--                     local output = vim.split(vim.api.nvim_exec(script, true), "\n")
--                     output = output[#output - 1]
--                     if #lines == 1 then
--                         vim.api.nvim_buf_set_text(0, from_pos[1], from_pos[2], to_pos[1], to_pos[2], { output })
--                     end
--                 end,
--             },
--         },
--     }),
-- }, {})

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

return {
  s({ trig = "begin" }, {
    t "\\begin{",
    i(1),
    t { "}", "\t" },
    i(0),
    t { "", "\\end{" },
    rep(1),
    t "}",
  }),
  s({ trig = "frame" }, {
    t "\\begin{frame}{",
    i(1),
    t { "}\\addframelabel{}", "\t" },
    i(0),
    t { "", "\\end{frame}" },
  }),
  s({ trig = "section" }, {
    t "\\section{",
    i(1),
    t "}",
    d(2, function(args)
      local text
      if args[1] == "" then
        text = "section"
      else
        text = args[1][1]:gsub(" ", "_"):lower()
      end
      return sn(nil, { t "\\label{sec:", i(1, text), t "}", t { "", "" }, i(0) })
    end, { 1 }),
  }),
  s({ trig = "chapter" }, {
    t "\\chapter{",
    i(1),
    t "}",
    d(2, function(args)
      local text
      if args[1] == "" then
        text = "section"
      else
        text = args[1][1]:gsub(" ", "_"):lower()
      end
      return sn(nil, { t "\\label{chap:", i(1, text), t "}", t { "", "" }, i(0) })
    end, { 1 }),
  }),
  s({ trig = "subsection" }, {
    t "\\subsection{",
    i(1),
    t "}",
    d(2, function(args)
      local text
      if args[1] == "" then
        text = "section"
      else
        text = args[1][1]:gsub(" ", "_"):lower()
      end
      return sn(nil, { t "\\label{subsec:", i(1, text), t "}", t { "", "" }, i(0) })
    end, { 1 }),
  }),
  s({ trig = "figtikz" }, {
    t {
      "\\begin{figure}[h]",
      "\t\\centering",
      "\t\\tikzfig{",
    },
    i(1),
    t {
      "}",
      "\t\\caption{",
    },
    i(3),
    t {
      "}",
      "\t",
    },
    d(2, function(args)
      local text
      print(vim.inspect(args[1]))
      if args[1][1] == "" then
        text = "figure"
      else
        text = args[1][1]:match("([^/]+)$"):lower()
      end
      return sn(nil, { t "\\label{fig:", i(1, text), t { "}", "" }, i(0) })
    end, { 1 }),
    t { "\\end{figure}", "" },
    i(0),
  }),
  s("rm", { t "\\textrm{", i(1), t "}", i(0) }),
  s("bold", { t "\\textbf{", i(1), t "}", i(0) }),
  s("italic", { t "\\textit{", i(1), t "}", i(0) }),
  s("smallcaps", { t "\\textsc{", i(1), t "}", i(0) }),
  s("emph", { t "\\emph{", i(1), t "}", i(0) }),
},

{
  s("$$", { t "\\( ", i(1), t " \\)", i(0) }),
  s({ trig = "([^%s%$]+)%$", trigEngine = balanced_engine, priority = 1001 }, {
    t "\\( ",
    f(function(_, snip, _)
      return snip.captures[1]
    end),
    t " \\)",
  }),
}

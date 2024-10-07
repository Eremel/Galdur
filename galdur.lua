--- STEAMODDED HEADER
--- MOD_NAME: Galdur
--- MOD_ID: galdur
--- PREFIX: galdur
--- MOD_AUTHOR: [Eremel_]
--- MOD_DESCRIPTION: A modification to the run setup screen to ease use.
--- BADGE_COLOUR: 3FC7EB
--- PRIORITY: -10000
--- VERSION: 1.1.4
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-0813a]

-- Definitions
Galdur = SMODS.current_mod
Galdur.clean_up_functions = {}
Galdur.pages_to_add = {}
Galdur.run_setup = {
    choices = {
        deck = nil,
        stake = nil,
        seed = ""
    },
    deck_select_areas = {},
    current_page = 1,
    pages = {},
    selected_deck_height = 52,
}
Galdur.quick_start = {}
Galdur.quick_start_texts = {}
Galdur.deck_preview_texts = {
    deck_preview_1 = '',
    deck_preview_2 = ''
}
Galdur.test_mode = false
Galdur.hover_index = 0
G.E_MANAGER.queues.galdur = {}

SMODS.Atlas({ -- art by nekojoe
    key = 'locked_stake',
    path = 'locked_stake.png',
    px = 29,
    py = 29
})


-- Function Hooks
local card_stop_hover = Card.stop_hover
function Card:stop_hover()
    if self.params.stake_chip then
        Galdur.hover_index = 0
    end
    card_stop_hover(self)
end

local card_hover_ref = Card.hover
function Card:hover()
    if self.params.deck_select and (not self.states.drag.is or G.CONTROLLER.HID.touch) and not self.no_ui and not G.debug_tooltip_toggle then
        self:juice_up(0.05, 0.03)
        play_sound('paper1', math.random()*0.2 + 0.9, 0.35)
        if self.children.alert and not self.config.center.alerted then
            self.config.center.alerted = true
            G:save_progress()
        end

        local col = self.params.deck_preview and G.UIT.C or G.UIT.R
        local info_col = self.params.deck_preview and G.UIT.R or G.UIT.C
        local back = Back(self.config.center)

        local info_queue = populate_info_queue('Back', back.effect.center.key)
        local tooltips = {}
        if self.config.center.unlocked then
            for _, center in pairs(info_queue) do
                local desc = generate_card_ui(center, {main = {},info = {},type = {},name = 'done',badges = badges or {}}, nil, center.set, nil)
                tooltips[#tooltips + 1] =
                {n=info_col, config={align = "tm"}, nodes={
                    {n=G.UIT.R, config={align = "cm", colour = lighten(G.C.JOKER_GREY, 0.5), r = 0.1, padding = 0.05, emboss = 0.05}, nodes={
                    info_tip_from_rows(desc.info[1], desc.info[1].name),
                    }}
                }}
            end
        end
        local badges = {n=G.UIT.ROOT, config = {colour = G.C.CLEAR, align = 'cm'}, nodes = {}}
        SMODS.create_mod_badges(self.config.center, badges.nodes)
        if badges.nodes.mod_set then badges.nodes.mod_set = nil end

        self.config.h_popup = {n=G.UIT.C, config={align = "cm", padding=0.1}, nodes={
            (self.params.deck_select > 6 and {n=col, config={align='cm', padding=0.1}, nodes = tooltips} or {n=G.UIT.R}),
            {n=col, config={align=(self.params.deck_preview and 'bm' or 'cm')}, nodes = {
                {n=G.UIT.C, config={align = "cm", minh = 1.5, r = 0.1, colour = G.C.L_BLACK, padding = 0.1, outline=1}, nodes={
                    {n=G.UIT.R, config={align = "cm", r = 0.1, minw = 3, maxw = 4, minh = 0.4}, nodes={
                        {n=G.UIT.O, config={object = UIBox{definition =
                            {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
                                {n=G.UIT.O, config={object = DynaText({string = back:get_name(),maxw = 4, colours = {G.C.WHITE}, shadow = true, bump = true, scale = 0.5, pop_in = 0, silent = true})}},
                            }},
                        config = {offset = {x=0,y=0}, align = 'cm', parent = e}}}
                        },
                    }},
                    {n=G.UIT.R, config={align = "cm", colour = G.C.WHITE, minh = 1.3, maxh = 3, minw = 3, maxw = 4, r = 0.1}, nodes={
                        {n=G.UIT.O, config={object = UIBox{definition = back:generate_UI(), config = {offset = {x=0,y=0}}}}}
                    }},
                    badges.nodes[1] and {n=G.UIT.R, config={align = "cm", r = 0.1, minw = 3, maxw = 4, minh = 0.4}, nodes={
                        {n=G.UIT.O, config={object = UIBox{definition = badges, config = {offset = {x=0,y=0}}}}}
                    }},
                }}
            }},
            (self.params.deck_select < 7 and {n=col, config={align=(self.params.deck_preview and 'bm' or 'cm'), padding=0.1}, nodes = tooltips} or {n=G.UIT.R})
            
        }}
        self.config.h_popup_config = self:align_h_popup()

        Node.hover(self)
    elseif self.params.stake_chip and (not self.states.drag.is or G.CONTROLLER.HID.touch) and not self.no_ui and not G.debug_tooltip_toggle then
        Galdur.hover_index = self.params.hover or 0
        self:juice_up(0.05, 0.03)
        play_sound('paper1', math.random()*0.2 + 0.9, 0.35)

        local info_queue = populate_info_queue('Stake', G.P_CENTER_POOLS.Stake[self.params.stake].key)
        local tooltips = {}
        for _, center in pairs(info_queue) do
            local desc = generate_card_ui(center, {main = {},info = {},type = {},name = 'done'}, nil, center.set, nil)
            tooltips[#tooltips + 1] =
            {n=G.UIT.C, config={align = "bm"}, nodes={
                {n=G.UIT.R, config={align = "cm", colour = lighten(G.C.JOKER_GREY, 0.5), r = 0.1, padding = 0.05, emboss = 0.05}, nodes={
                  info_tip_from_rows(desc.info[1], desc.info[1].name),
                }}
            }}
        end
        
        local badges = {n=G.UIT.ROOT, config = {colour = G.C.CLEAR, align = 'cm'}, nodes = {}}
        SMODS.create_mod_badges(G.P_CENTER_POOLS.Stake[self.params.stake], badges.nodes)
        if badges.nodes.mod_set then badges.nodes.mod_set = nil end


        self.config.h_popup = self.params.stake_chip_locked and {n=G.UIT.ROOT, config={align = "cm", colour = G.C.BLACK, r = 0.1, padding = 0.1, outline = 1}, nodes={
            {n=G.UIT.C, config={align = "cm", padding = 0.05, r = 0.1, colour = G.C.L_BLACK}, nodes={
                {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
                  {n=G.UIT.T, config={text = localize('gald_locked'), scale = 0.4, colour = G.C.WHITE}}
                }},
                {n=G.UIT.R, config={align = "cm", padding = 0.03, colour = G.C.WHITE, r = 0.1, minh = 1, minw = 3.5}, nodes=
                    create_stake_unlock_message(G.P_CENTER_POOLS.Stake[self.params.stake])
                }
              }}
        }} or {n = G.UIT.ROOT, config={align='cm', colour = G.C.CLEAR}, nodes = {
            {n=G.UIT.R, config={align='cm', padding=0.1}, nodes = tooltips},
            {n=G.UIT.C, config={align = "cm", padding = 0.1, colour = G.C.BLACK, r = 0.1, outline = 1}, nodes={    
                {n=G.UIT.R, nodes = {
                    {n=G.UIT.C, config={align = "cm", padding = 0}, nodes={
                        {n=G.UIT.T, config={text = localize('k_stake'), scale = 0.4, colour = G.C.L_BLACK, vert = true}}
                    }},
                    {n=G.UIT.C, config={align = "cm", padding = 0}, nodes={
                        {n=G.UIT.O, config={colour = G.C.BLUE, object = get_stake_sprite(self.params.stake), hover = true, can_collide = false}},
                    }},
                    {n=G.UIT.C, config={align = "cm", padding = 0}, nodes={
                        G.UIDEF.stake_description(self.params.stake)
                    }}
                }},
                badges.nodes[1] and {n=G.UIT.R, config={ align = "cm"}, nodes={
                    {n=G.UIT.O, config={object = UIBox{definition = badges, config = {offset = {x=0,y=0}}}}}
                }},
            }}
        }}

        self.config.h_popup_config = self:align_h_popup()
        Node.hover(self)
    else
       card_hover_ref(self) 
    end
end

local card_click_ref = Card.click
function Card:click() 
    if self.deck_select_position and self.config.center.unlocked then
        Galdur.run_setup.selected_deck_from = self.area.config.index
        Galdur.run_setup.choices.deck = Back(self.config.center)
        -- Galdur.run_setup.choices.stake = get_deck_win_stake(Galdur.run_setup.choices.deck.effect.center.key)
        Galdur.set_new_deck()
    elseif self.params.stake_chip and not self.params.stake_chip_locked then
        Galdur.run_setup.choices.stake = self.params.stake
        G.E_MANAGER:clear_queue('galdur')
        Galdur.populate_chip_tower(self.params.stake)
    else
        card_click_ref(self)
    end
end

local card_area_align_ref = CardArea.align_cards
function CardArea:align_cards()
    if self.config.stake_chips then -- align chips vertically in chip tower
        local deck_height = 4.8/math.max(48,#self.cards)
        for k, card in ipairs(self.cards) do
            if not card.states.drag.is then
                card.T.x = self.T.x + 0.5*(self.T.w - card.T.w)
                card.T.y = self.T.y + deck_height - (#self.cards - k + (k <= Galdur.hover_index and 7 or 0))*deck_height  --self.shadow_parrallax.y*deck_height*(#self.cards/(self == G.deck and 1 or 2) - k)
            end
            card.rank = k
        end
    elseif self.config.selected_deck then -- deck preview grows vertically
        local deck_height = (self.config.deck_height or 0.15)/52
        for k, card in ipairs(self.cards) do
            if card.facing == 'front' then card:flip() end

            if not card.states.drag.is then
                card.T.x = self.T.x + 0.5*(self.T.w - card.T.w)
                card.T.y = self.T.y + 0.5*(self.T.h - card.T.h) + self.shadow_parrallax.y*deck_height*(#self.cards/(self == G.deck and 1 or 2) - k)
            end
        end
    else
        card_area_align_ref(self)
    end
end

local exit_overlay = G.FUNCS.exit_overlay_menu
G.FUNCS.exit_overlay_menu = function()
    if Galdur.config.use and (Galdur.run_setup.deck_select_areas or Galdur.run_setup.stake_select_areas) then
        for _, clean_up in pairs(Galdur.clean_up_functions) do
            clean_up()
        end
        G.E_MANAGER:clear_queue('galdur')
    end
    exit_overlay()
end

  -- Deck Selection Functions
function generate_deck_card_areas()
    if Galdur.run_setup.deck_select_areas then
        for i=1, #Galdur.run_setup.deck_select_areas do
            for j=1, #G.I.CARDAREA do
                if Galdur.run_setup.deck_select_areas[i] == G.I.CARDAREA[j] then
                    table.remove(G.I.CARDAREA, j)
                    Galdur.run_setup.deck_select_areas[i] = nil
                end
            end
        end
    end
    Galdur.run_setup.deck_select_areas = {}
    for i=1, 12 do
        Galdur.run_setup.deck_select_areas[i] = CardArea(G.ROOM.T.w,G.ROOM.T.h, G.CARD_W, G.CARD_H, 
        {card_limit = 5, type = 'deck', highlight_limit = 0, deck_height = 0.75, thin_draw = 1, deck_select = true, index = i})
    end
end

function generate_deck_card_areas_ui()
    local deck_ui_element = {}
    local count = 1
    for i=1, 2 do
        local row = {n = G.UIT.R, config = {colour = G.C.LIGHT}, nodes = {}}
        for j=1, 6 do
            if count > #G.P_CENTER_POOLS.Back then return end
            table.insert(row.nodes, {n = G.UIT.O, config = {object = Galdur.run_setup.deck_select_areas[count], r = 0.1, id = "deck_select_"..count}})
            count = count + 1
        end
        table.insert(deck_ui_element, row)
    end

    populate_deck_card_areas(1)

    return {n=G.UIT.R, config={align = "cm", minh = 3.3, minw = 5, colour = G.C.BLACK, padding = 0.15, r = 0.1, emboss = 0.05}, nodes=deck_ui_element}
end

function populate_deck_card_areas(page)
    local count = 1 + (page - 1) * 12
    for i=1, 12 do
        if count > #G.P_CENTER_POOLS.Back then return end
        local card_number = Galdur.config.reduce and 1 or 10
        for index = 1, card_number do
            local card = Card(Galdur.run_setup.deck_select_areas[i].T.x,Galdur.run_setup.deck_select_areas[i].T.y, G.CARD_W, G.CARD_H, G.P_CENTER_POOLS.Back[count], G.P_CENTER_POOLS.Back[count],
                {galdur_back = Back(G.P_CENTER_POOLS.Back[count]), deck_select = i})
            card.sprite_facing = 'back'
            card.facing = 'back'
            card.children.back = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS[G.P_CENTER_POOLS.Back[count].unlocked and G.P_CENTER_POOLS.Back[count].atlas or 'centers'], G.P_CENTER_POOLS.Back[count].unlocked and G.P_CENTER_POOLS.Back[count].pos or {x = 4, y = 0})
            card.children.back.states.hover = card.states.hover
            card.children.back.states.click = card.states.click
            card.children.back.states.drag = card.states.drag
            card.children.back.states.collide.can = false
            card.children.back:set_role({major = card, role_type = 'Glued', draw_major = card})
            if not Galdur.run_setup.deck_select_areas[i].cards then Galdur.run_setup.deck_select_areas[i].cards = {} end
            Galdur.run_setup.deck_select_areas[i]:emplace(card)
            if index == card_number then
                card.sticker = get_deck_win_sticker(G.P_CENTER_POOLS.Back[count])
                card.deck_select_position = {page = page, count = i}
            end
        end
        count = count + 1
    end
end

function Galdur.set_new_deck(silent)
    G.E_MANAGER:clear_queue('galdur')
    Galdur.populate_deck_preview(Galdur.run_setup.choices.deck, silent)

    local deck_name = split_string_2(Galdur.run_setup.choices.deck.loc_name)
    Galdur.deck_preview_texts.deck_preview_1 = deck_name[1]
    Galdur.deck_preview_texts.deck_preview_2 = deck_name[2]

    for i=1, 2 do
        local dyna_text_object = G.OVERLAY_MENU:get_UIE_by_ID('deck_name_'..i).config.object
        dyna_text_object.scale = 0.7/math.max(1, string.len(Galdur.deck_preview_texts['deck_preview_'..i])/8)
    end
end

function Galdur.clean_up_functions.clean_deck_areas()
    if not Galdur.run_setup.deck_select_areas then return end
    for j = 1, #Galdur.run_setup.deck_select_areas do
        if Galdur.run_setup.deck_select_areas[j].cards then
            remove_all(Galdur.run_setup.deck_select_areas[j].cards)
            Galdur.run_setup.deck_select_areas[j].cards = {}
        end
    end
end

function create_deck_page_cycle()
    local options = {}
    local cycle
    if #G.P_CENTER_POOLS.Back > 12 then
        local total_pages = math.ceil(#G.P_CENTER_POOLS.Back / 12)
        for i=1, total_pages do
            table.insert(options, localize('k_page')..' '..i..' / '..total_pages)
        end
        cycle = create_option_cycle({
            options = options,
            w = 4.5,
            cycle_shoulders = true,
            opt_callback = 'change_deck_page',
            focus_args = { snap_to = true, nav = 'wide' },
            current_option = 1,
            colour = G.C.RED,
            no_pips = true
        })
    end
    return {n = G.UIT.R, config = {align = "cm"}, nodes = {cycle}}
end

G.FUNCS.change_deck_page = function(args)
    Galdur.clean_up_functions.clean_deck_areas()
    populate_deck_card_areas(args.cycle_config.current_option)
end

-- Stake Selection Functions
function generate_stake_card_areas()
    if Galdur.run_setup.stake_select_areas then
        for i=1, #Galdur.run_setup.stake_select_areas do
            for j=1, #G.I.CARDAREA do
                if Galdur.run_setup.stake_select_areas[i] == G.I.CARDAREA[j] then
                    table.remove(G.I.CARDAREA, j)
                    Galdur.run_setup.stake_select_areas[i] = nil
                end
            end
        end
    end
    Galdur.run_setup.stake_select_areas = {}
    for i=1, 24 do
        Galdur.run_setup.stake_select_areas[i] = CardArea(G.ROOM.T.w * 0.116, G.ROOM.T.h * 0.209, 3.4*14/41, 3.4*14/41, 
        {card_limit = 1, type = 'deck', highlight_limit = 0, stake_select = true})
    end
end

function generate_stake_card_areas_ui()
    local stake_ui_element = {}
    local count = 1
    for i=1, 3 do
        local row = {n = G.UIT.R, config = {colour = G.C.LIGHT, padding = 0.1}, nodes = {}}
        for j=1, 8 do
            table.insert(row.nodes, {n = G.UIT.O, config = {object = Galdur.run_setup.stake_select_areas[count], r = 0.1, id = "stake_select_"..count, outline_colour = G.C.YELLOW}})
            count = count + 1
        end
        table.insert(stake_ui_element, row)
    end

    populate_stake_card_areas(1)

    return {n=G.UIT.R, config={align = "cm", minh = 0.45+G.CARD_H+G.CARD_H, minw = 10.7, colour = G.C.BLACK, padding = 0.15, r = 0.1, emboss = 0.05}, nodes=stake_ui_element}
end

function get_stake_sprite_in_area(_stake, _scale, _area)
    _stake = _stake or 1
    _scale = _scale or 1
    _area = _area.T or {x = 0, y = 0}
    local stake_sprite = Sprite(_area.x, _area.y, _scale*1, _scale*1,G.ASSET_ATLAS[G.P_CENTER_POOLS.Stake[_stake].atlas], G.P_CENTER_POOLS.Stake[_stake].pos)
    stake_sprite.states.drag.can = false
    if G.P_CENTER_POOLS['Stake'][_stake].shiny then
        stake_sprite.draw = function(_sprite)
            _sprite.ARGS.send_to_shader = _sprite.ARGS.send_to_shader or {}
            _sprite.ARGS.send_to_shader[1] = math.min(_sprite.VT.r*3, 1) + G.TIMERS.REAL/(18) + (_sprite.juice and _sprite.juice.r*20 or 0) + 1
            _sprite.ARGS.send_to_shader[2] = G.TIMERS.REAL

            if _sprite.won then
                if Galdur.config.stake_colour == 1 then
                    Sprite.draw_shader(_sprite, 'dissolve')
                    Sprite.draw_shader(_sprite, 'voucher', nil, _sprite.ARGS.send_to_shader)
                else
                    Sprite.draw_self(_sprite, G.C.L_BLACK) 
                end
            else
                if Galdur.config.stake_colour == 2 then
                    Sprite.draw_shader(_sprite, 'dissolve')
                    Sprite.draw_shader(_sprite, 'voucher', nil, _sprite.ARGS.send_to_shader)
                else
                    Sprite.draw_self(_sprite, G.C.L_BLACK) 
                end
            end
        end
    end
    return stake_sprite
end

function populate_stake_card_areas(page)
    local count = 1 + (page - 1) * 24
    for i=1, 24 do
        if count > #G.P_CENTER_POOLS.Stake then return end
        local card = Card(Galdur.run_setup.stake_select_areas[i].T.x,Galdur.run_setup.stake_select_areas[i].T.y, 3.4*14/41, 3.4*14/41,
            Galdur.run_setup.choices.deck.effect.center, Galdur.run_setup.choices.deck.effect.center, {stake_chip = true, stake = count, galdur_selector = true})
        card.facing = 'back'
        card.sprite_facing = 'back'
        card.children.back = get_stake_sprite_in_area(count, 3.4*14/41, card)
    
        local unlocked = true
        local save_data = G.PROFILES[G.SETTINGS.profile].deck_usage[Galdur.run_setup.choices.deck.effect.center.key]  and G.PROFILES[G.SETTINGS.profile].deck_usage[Galdur.run_setup.choices.deck.effect.center.key].wins_by_key or {}
        for _,v in ipairs(G.P_CENTER_POOLS.Stake[count].applied_stakes) do
            if not G.PROFILES[G.SETTINGS.profile].all_unlocked and not Galdur.config.unlock_all and (not save_data or (save_data and not save_data['stake_'..v])) then
                unlocked = false
            end
        end
        if save_data and save_data[G.P_CENTER_POOLS.Stake[count].key] then
            card.children.back.won = true
            unlocked = true
        end
        if not unlocked then
            card.params.stake_chip_locked = true
            card.children.back = Sprite(card.T.x, card.T.y, 3.4*14/41, 3.4*14/41,G.ASSET_ATLAS['galdur_locked_stake'], {x=0,y=0})
        end
        card.children.back.states.hover = card.states.hover
        card.children.back.states.click = card.states.click
        card.children.back.states.drag = card.states.drag
        card.states.collide.can = false
        card.children.back:set_role({major = card, role_type = 'Glued', draw_major = card})
        Galdur.run_setup.stake_select_areas[i]:emplace(card)
        count = count + 1
    end
end

function Galdur.clean_up_functions.clean_stake_areas()
    if not Galdur.run_setup.stake_select_areas then return end
    for j = 1, #Galdur.run_setup.stake_select_areas do
        if Galdur.run_setup.stake_select_areas[j].cards then
            remove_all(Galdur.run_setup.stake_select_areas[j].cards)
            Galdur.run_setup.stake_select_areas[j].cards = {}
        end
    end
end

function create_stake_page_cycle()
    local options = {}
    local total_pages = math.ceil(#G.P_CENTER_POOLS.Stake / 24)
    for i=1, total_pages do
        table.insert(options, localize('k_page')..' '..i..' / '..total_pages)
    end
    local cycle = create_option_cycle({
        options = options,
        w = 4.5,
        cycle_shoulders = true,
        opt_callback = 'change_stake_page',
        focus_args = { snap_to = true, nav = 'wide' },
        current_option = 1,
        colour = G.C.RED,
        no_pips = true
    })
    
    return {n = G.UIT.R, config = {align = "cm"}, nodes = {cycle}}
end

G.FUNCS.change_stake_page = function(args)
    Galdur.clean_up_functions.clean_stake_areas()
    populate_stake_card_areas(args.cycle_config.current_option)
end

-- Main Select Functions
function G.UIDEF.run_setup_option_new_model(type)
     for _, args in ipairs(Galdur.pages_to_add) do
        if not args.definition or localize(args.name) == "ERROR" then
            sendErrorMessage(localize('gald_new_page_error'), "Galdur")
        else
            table.insert(Galdur.run_setup.pages, args)
        end
    end
    Galdur.pages_to_add = {}
    
    if not G.SAVED_GAME then
        G.SAVED_GAME = get_compressed(G.SETTINGS.profile..'/'..'save.jkr')
        if G.SAVED_GAME ~= nil then G.SAVED_GAME = STR_UNPACK(G.SAVED_GAME) end
    end
  
    G.SETTINGS.current_setup = type
    Galdur.run_setup.choices.deck = Back(get_deck_from_name(G.PROFILES[G.SETTINGS.profile].MEMORY.deck))
    G.PROFILES[G.SETTINGS.profile].MEMORY.stake = G.PROFILES[G.SETTINGS.profile].MEMORY.stake or 1
    Galdur.run_setup.choices.stake = G.PROFILES[G.SETTINGS.profile].MEMORY.stake
    if Galdur.run_setup.choices.stake > #G.P_CENTER_POOLS.Stake then Galdur.run_setup.choices.stake = 1 end
    Galdur.quick_start.deck = Galdur.run_setup.choices.deck
    Galdur.quick_start.stake = Galdur.run_setup.choices.stake
    Galdur.run_setup.choices.seed = ''
    local seed_unlocker_present = (SMODS.Mods['SeedUnlocker'] or {}).can_load
    
    
    local deck_name = split_string_2(Galdur.run_setup.choices.deck.loc_name)
    Galdur.deck_preview_texts.deck_preview_1 = deck_name[1]
    Galdur.deck_preview_texts.deck_preview_2 = deck_name[2]
    
    generate_deck_card_areas()
    generate_stake_card_areas()
    
    Galdur.run_setup.current_page = 1
    Galdur.run_setup.pages.prev_button = ""
    Galdur.run_setup.pages.next_button = localize(Galdur.run_setup.pages[2].name) .. ' >'
    local quick_select_text = {}
    for _, func in ipairs(Galdur.quick_start_texts) do
        table.insert(quick_select_text, func())
    end
    local Taiko_pres = (SMODS.Mods['Taikomochi'] or {}).can_load
    local t =
    {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR, minh = 6.6, minw = 6}, nodes={
        {n = G.UIT.C, nodes = {
            {n=G.UIT.R, config = {align = "cm", minw = 3}, nodes ={
                {n = G.UIT.O, config = {id = 'deck_select_pages', object = UIBox{
                    definition = Galdur.run_setup.pages[Galdur.run_setup.current_page].definition(),
                    config = {align = "cm", offset = {x=0,y=0}}
                }}},
            }},
            {n=G.UIT.R, config = {align = "cm", minw = 3, offset = {x=0, y=-5}}, nodes ={
                {n = G.UIT.C, config={align='cm'}, nodes = {
                    {n=G.UIT.R, config = {id = 'previous_selection', minw = 2.5, minh = 0.8, maxh = 0.8, r = 0.1,
                        hover = true, ref_value = -1, button = Galdur.run_setup.current_page > 1 and 'deck_select_next' or function() end,
                        colour = Galdur.run_setup.current_page > 1 and G.C.BLUE or G.C.CLEAR, align = "cm",
                        emboss = Galdur.run_setup.current_page > 1 and 0.1 or 0},
                        nodes = {
                            {n=G.UIT.T, config={ref_table = Galdur.run_setup.pages, ref_value = 'prev_button', scale = 0.4, colour = G.C.WHITE}},
                    }}
                }},
                {n=G.UIT.C, config={align = "cm", padding = 0.05, minh = 0.9, minw = 6.6}, nodes={
                    {n=G.UIT.O, config={id = 'seed_input', align = "cm", object = Galdur.run_setup.choices.seed_select and UIBox{
                        definition = {n=G.UIT.ROOT, config={align = "cr", colour = G.C.CLEAR}, nodes={
                          {n=G.UIT.C, config={align = "cm", minw = 2.5, padding = 0.05}, nodes={
                            simple_text_container('ml_disabled_seed',{colour = G.C.UI.TEXT_LIGHT, scale = 0.26, shadow = true}),
                          }},
                          {n=G.UIT.C, config={align = "cm", minw = 0.1}, nodes={
                            {n=G.UIT.C, config={maxw = 3.1}, nodes = {
                                seed_unlocker_present and
                                create_text_input({max_length = 2500, extended_corpus = true, ref_table = Galdur.run_setup.choices, ref_value = 'seed', prompt_text = localize('k_enter_seed')})
                             or create_text_input({max_length = 8, all_caps = true, ref_table = Galdur.run_setup.choices, ref_value = 'seed', prompt_text = localize('k_enter_seed')}),
                            }},
                            {n=G.UIT.C, config={align = "cm", minw = 0.1}, nodes={}},
                            UIBox_button({label = localize('ml_paste_seed'),minw = 1, minh = 0.6, button = 'paste_seed', colour = G.C.BLUE, scale = 0.3, col = true})
                          }}
                        }},
                        config = {offset = {x=0,y=0}, parent = e, type = 'cm'}
                    } or Moveable()}, nodes={}},
                }},
                {n=G.UIT.C, config={align = "cm", minw = 2.2, id = 'run_setup_seed'}, nodes={
                    {n=G.UIT.R, config={align='cr'}, nodes = {create_toggle{col = true, label = localize('k_seeded_run'), label_scale = 0.25, w = 0, scale = 0.7,
                        callback = G.FUNCS.toggle_seeded_run_galdur, ref_table = Galdur.run_setup.choices, ref_value = 'seed_select'}}},
                    {n=G.UIT.R, config={align='cr'}, nodes = {Taiko_pres and create_toggle{col = true, label = "Zen Mode", label_scale = 0.25, w = 0, scale = 0.7,
                        ref_table = G, ref_value = 'run_zen_mode', active_colour = G.C.BLUE} or nil}}
                }},
                {n = G.UIT.C, config={align='cm'}, nodes = {
                    {n=G.UIT.R, config = {id = 'next_selection', minw = 2.5, minh = 0.8, maxh = 0.8, r = 0.1, hover = true, ref_value = 1,
                        button = 'deck_select_next', colour = G.C.BLUE,
                        align = "cm", emboss = 0.1}, nodes = {
                            {n=G.UIT.T, config={ref_table = Galdur.run_setup.pages, ref_value = 'next_button', scale = 0.4, colour = G.C.WHITE}},
                    }}
                }},
                {n=G.UIT.C, config={minw = 0.5}},
                {n = G.UIT.C, config={align='cm'}, nodes = {{n=G.UIT.R, config = {maxw = 2.5, minw = 2.5, minh = 0.8, r = 0.1, hover = true, ref_value = 1,
                    button = 'quick_start', colour = G.C.ORANGE, align = "cm", emboss = 0.1, tooltip = {text = quick_select_text} }, nodes = {
                        {n=G.UIT.T, config={text = localize('gald_quick_start'), scale = 0.4, colour = G.C.WHITE}}
                }}}}
            }}
        }}
    }}
    return t
end

G.FUNCS.deck_select_next = function(e)
    for _, clean_up in pairs(Galdur.clean_up_functions) do
        clean_up()
    end
    -- Check for function when confirming selection
    if Galdur.run_setup.pages[Galdur.run_setup.current_page].confirm and type(Galdur.run_setup.pages[Galdur.run_setup.current_page].confirm) == 'function' then
        Galdur.run_setup.pages[Galdur.run_setup.current_page].confirm()
    end

    Galdur.run_setup.current_page = math.min(math.max(Galdur.run_setup.current_page + e.config.ref_value, 1), #Galdur.run_setup.pages+1)

    if Galdur.run_setup.current_page > #Galdur.run_setup.pages then
        Galdur.start_run()
        return
    elseif Galdur.run_setup.current_page == #Galdur.run_setup.pages then
        Galdur.run_setup.pages.next_button = localize('gald_play')
    else
        Galdur.run_setup.pages.next_button = localize(Galdur.run_setup.pages[Galdur.run_setup.current_page+1].name) .. ' >'
    end
    if Galdur.run_setup.current_page == 1 then
        Galdur.run_setup.pages.prev_button = " "
    else
        Galdur.run_setup.pages.prev_button = '< ' .. localize(Galdur.run_setup.pages[Galdur.run_setup.current_page-1].name)
    end

    local next_button = e.UIBox:get_UIE_by_ID('next_selection')
    next_button.config.colour = Galdur.run_setup.current_page == #Galdur.run_setup.pages and HEX('00be67') or G.C.BLUE

    local prev_button = e.UIBox:get_UIE_by_ID('previous_selection')
    prev_button.config.button = Galdur.run_setup.current_page > 1 and 'deck_select_next' or nil
    prev_button.config.emboss = Galdur.run_setup.current_page > 1 and 0.1 or 0
    prev_button.config.hover = Galdur.run_setup.current_page > 1 and true or false
    prev_button.config.colour = Galdur.run_setup.current_page > 1 and G.C.BLUE or G.C.CLEAR
    prev_button.UIBox:recalculate()

    local current_selector_page = e.UIBox:get_UIE_by_ID('deck_select_pages')
    if not current_selector_page then return end
    current_selector_page.config.object:remove()
    current_selector_page.config.object = UIBox{
        definition = Galdur.run_setup.pages[Galdur.run_setup.current_page].definition(),
        config = {offset = {x=0,y=0}, parent = current_selector_page, type = 'cm'}
    }
    current_selector_page.UIBox:recalculate()
end

function Galdur.start_run(_quick_start)
    if not Galdur.run_setup.choices.seed_select or Galdur.run_setup.choices.seed == '' then Galdur.run_setup.choices.seed = nil end
    if _quick_start then
        Galdur.run_setup.choices.deck = Galdur.quick_start.deck
        Galdur.run_setup.choices.stake = Galdur.quick_start.stake
    end
    G.PROFILES[G.SETTINGS.profile].MEMORY.deck = Galdur.run_setup.choices.deck.effect.center.name
    G.PROFILES[G.SETTINGS.profile].MEMORY.stake = Galdur.run_setup.choices.stake
    for _,page in ipairs(Galdur.run_setup.pages) do
        if page.pre_start and type(page.pre_start) == 'function' then
            page.pre_start(Galdur.run_setup.choices)
        end
    end

    G.FUNCS.start_run(nil, Galdur.run_setup.choices)

    for _,page in ipairs(Galdur.run_setup.pages) do
        if page.post_start and type(page.post_start) == 'function' then
            page.post_start(Galdur.run_setup.choices)
        end
    end
end

G.FUNCS.quick_start = function(e)
    Galdur.start_run(true)
end

G.FUNCS.random_deck = function()
    local selected = false
    local random_deck_opts = {}
    for i=1, #G.P_CENTER_POOLS.Back do
        if G.P_CENTER_POOLS.Back[i].unlocked then
            random_deck_opts[#random_deck_opts + 1] = i
        end
    end
    while not selected do
        local random = pseudorandom_element(random_deck_opts, pseudoseed(os.time()))
        selected = Back(G.P_CENTER_POOLS.Back[random_deck_opts[random]])
        if selected == Galdur.run_setup.choices.deck and #random_deck_opts > 1 then selected = false end
    end
    play_sound('whoosh1', math.random()*0.2 + 0.9, 0.35)
    Galdur.run_setup.choices.deck = selected
    Galdur.set_new_deck()
end

G.FUNCS.random_stake = function()
    local random_stake_opts = {}
    for i=1, #G.P_CENTER_POOLS.Stake do
        local unlocked = true
        local save_data = G.PROFILES[G.SETTINGS.profile].deck_usage[Galdur.run_setup.choices.deck.effect.center.key]  and G.PROFILES[G.SETTINGS.profile].deck_usage[Galdur.run_setup.choices.deck.effect.center.key].wins_by_key or {}
        for _,v in ipairs(G.P_CENTER_POOLS.Stake[i].applied_stakes) do
            if not G.PROFILES[G.SETTINGS.profile].all_unlocked and not Galdur.config.unlock_all and (not save_data or (save_data and not save_data['stake_'..v])) then
                unlocked = false
            end
        end
        if save_data and save_data[G.P_CENTER_POOLS.Stake[i].key] then
            unlocked = true
        end
        if unlocked then
            random_stake_opts[#random_stake_opts + 1] = i
        end
    end
    local selected = false
    while not selected do
        local random = pseudorandom_element(random_stake_opts, pseudoseed(os.time()))
        selected = random_stake_opts[random]
        if selected == Galdur.run_setup.choices.stake and #random_stake_opts > 1 then selected = false end
    end
    play_sound('whoosh1', math.random()*0.2 + 0.9, 0.35)
    Galdur.run_setup.choices.stake = selected
    Galdur.populate_chip_tower(selected)
end

function deck_select_page_deck()
    generate_deck_card_areas()
    Galdur.include_deck_preview(true)

    local deck_preview = Galdur.display_deck_preview()
    deck_preview.nodes[#deck_preview.nodes+1] = {n = G.UIT.R, config={align = 'cm', padding = 0.15}, nodes = {
        {n=G.UIT.R, config = {maxw = 2.5, minw = 2.5, minh = 0.8, r = 0.1, hover = true, ref_value = 1, button = 'random_deck', colour = Galdur.badge_colour, align = "cm", emboss = 0.1}, nodes = {
            {n=G.UIT.T, config={text = "Random Deck", scale = 0.4, colour = G.C.WHITE}}
        }}
    }}


    return 
        {n=G.UIT.ROOT, config={align = "tm", minh = 3.8, colour = G.C.CLEAR, padding=0.1}, nodes={
            {n=G.UIT.C, config = {padding = 0.15}, nodes ={   
                generate_deck_card_areas_ui(), 
                create_deck_page_cycle(),
            }},
            deck_preview
        }}
    
end

function deck_select_page_stake()
    generate_stake_card_areas()
    local chip_tower_options = {
        math.min(Galdur.run_setup.choices.stake, math.max(get_deck_win_stake(Galdur.run_setup.choices.deck.effect.center.key), 1)),
        math.min(get_deck_win_stake(Galdur.run_setup.choices.deck.effect.center.key) + 1, #G.P_CENTER_POOLS.Stake),
        1
    }
    Galdur.run_setup.choices.stake = chip_tower_options[Galdur.config.stake_select]
    Galdur.include_chip_tower(true)
    Galdur.include_deck_preview()

    local deck_preview = Galdur.display_deck_preview()
    deck_preview.nodes[#deck_preview.nodes+1] = {n = G.UIT.R, config={align = 'cm', padding = 0.15}, nodes = {
        {n=G.UIT.R, config = {maxw = 2.5, minw = 2.5, minh = 0.8, r = 0.1, hover = true, ref_value = 1, button = 'random_stake', colour = Galdur.badge_colour, align = "cm", emboss = 0.1}, nodes = {
            {n=G.UIT.T, config={text = "Random Stake", scale = 0.4, colour = G.C.WHITE}}
        }}
    }}

    return 
    {n=G.UIT.ROOT, config={align = "tm", minh = 3.8, colour = G.C.CLEAR, padding=0.1}, nodes={
        {n=G.UIT.C, config = {padding = 0.15}, nodes ={    
            generate_stake_card_areas_ui(),
            create_stake_page_cycle(),
        }},
        Galdur.display_chip_tower(),
        deck_preview
    }}
end

Galdur.add_new_page = function(args)
    if args.quick_start_text then
        Galdur.add_to_quick_start(args.quick_start_text, args.page)
    end
    table.insert(Galdur.pages_to_add, args.page or (#Galdur.pages_to_add + 1), args)
    -- Galdur.pages_to_add[#Galdur.pages_to_add + 1] = args
end

Galdur.add_to_quick_start = function(text_func, page)
    table.insert(Galdur.quick_start_texts, page or (#Galdur.quick_start_texts + 1), text_func)
end

Galdur.include_deck_preview = function(animate)
    generate_deck_card_areas()
    Galdur.generate_deck_preview()
    Galdur.populate_deck_preview(Galdur.run_setup.choices.deck, not animate)
end

Galdur.include_chip_tower = function(animate)
    Galdur.generate_chip_tower()
    Galdur.populate_chip_tower(Galdur.run_setup.choices.stake, not animate)
end

Galdur.add_new_page({
    definition = deck_select_page_deck,
    name = 'gald_select_deck',
    quick_start_text = function() return Galdur.run_setup.choices.deck:get_name() end
})
Galdur.add_new_page({
    definition = deck_select_page_stake,
    name = 'gald_select_stake',
    quick_start_text = function() return localize({type='name_text', set='Stake', key=G.P_CENTER_POOLS.Stake[Galdur.run_setup.choices.stake].key}) end
})

SMODS.current_mod.config_tab = function()
    local stake_colour_options = {}

    return {n = G.UIT.ROOT, config = {r = 0.1, minw = 4, align = "tm", padding = 0.2, colour = G.C.BLACK}, nodes = {
            {n=G.UIT.R, config = {align = 'cm'}, nodes={
                create_toggle({label = localize('gald_master'), ref_table = Galdur.config, ref_value = 'use', info = localize('gald_use_desc'), active_colour = Galdur.badge_colour, right = true}),
            }},
            {n=G.UIT.R, config={minh=0.1}},
            {n=G.UIT.R, config = {minh = 0.04, minw = 4.5, colour = G.C.L_BLACK}},
            {n=G.UIT.R, nodes = {
                {n=G.UIT.C, config={minw = 3, padding=0.2}, nodes={
                    create_toggle({label = localize('gald_anim'), ref_table = Galdur.config, ref_value = 'animation', info = localize('gald_anim_desc'), active_colour = Galdur.badge_colour, right = true}),
                    create_toggle({label = localize('gald_reduce'), ref_table = Galdur.config, ref_value = 'reduce', info = localize('gald_reduce_desc'), active_colour = Galdur.badge_colour, right = true}),
                    create_toggle({label = localize('gald_unlock'), ref_table = Galdur.config, ref_value = 'unlock_all', info = localize('gald_unlock_desc'), active_colour = Galdur.badge_colour, right = true}),
                }},
                {n=G.UIT.C, config={minw = 3, padding=0.1}, nodes={
                    {n=G.UIT.R, config={minh=0.1}},
                    create_option_cycle({label = localize('gald_stake_select'), current_option = Galdur.config.stake_select, options = localize('gald_stake_select_options'), ref_table = Galdur.config, ref_value = 'stake_select', info = localize('gald_stake_select_desc'), colour = Galdur.badge_colour, w = 3.7*0.65/(5/6), h=0.8*0.65/(5/6), text_scale=0.5*0.65/(5/6), scale=5/6, no_pips = true, opt_callback = 'cycle_update'}),
                    create_option_cycle({label = localize('gald_stake_colour'), current_option = Galdur.config.stake_colour, ref_table = Galdur.config, ref_value = 'stake_colour', options = localize('gald_stake_colour_options'), info = localize('gald_stake_colour_desc'), colour = Galdur.badge_colour, w = 3.7*0.65/(5/6), h=0.8*0.65/(5/6), text_scale=0.5*0.55/(5/6), scale=5/6, no_pips = true, opt_callback = 'cycle_update'}),
                }}
            }},
            
    }}
end

G.FUNCS.cycle_update = function(args)
    args = args or {}
    if args.cycle_config and args.cycle_config.ref_table and args.cycle_config.ref_value then
        args.cycle_config.ref_table[args.cycle_config.ref_value] = args.to_key
    end
end


-- Deck Preview Functions
function Galdur.display_deck_preview()
    local texts = split_string_2(Galdur.run_setup.choices.deck.loc_name)
    Galdur.deck_preview_texts.deck_name_1 = texts[1]
    Galdur.deck_preview_texts.deck_name_2 = texts[2]

    local deck_node = {n=G.UIT.R, config={align = "tm"}, nodes={
        {n = G.UIT.O, config = {object = Galdur.run_setup.selected_deck_area}}
    }}

    return 
    {n=G.UIT.C, config = {align = "tm", padding = 0.15}, nodes ={
        {n = G.UIT.R, config = {minh = 5.95, minw = 3, maxw = 3, colour = G.C.BLACK, r=0.1, align = "bm", padding = 0.15, emboss=0.05}, nodes = {
            {n = G.UIT.R, config = {align = "cm", minh = 0.6, maxw = 2.8}, nodes = {
                -- {n = G.UIT.T, config = {id = "selected_deck_name", text = texts[1], scale = 0.7/math.max(1,string.len(texts[1])/8), colour = G.C.GREY}},
                {n=G.UIT.O, config = {id = 'deck_name_1', object = DynaText({
                    string = {{ref_table = Galdur.deck_preview_texts, ref_value = 'deck_preview_1'}},
                    scale = 0.7/math.max(1, string.len(Galdur.deck_preview_texts.deck_preview_1)/8),
                    colours = {G.C.GREY},
                    pop_in_rate = 5,
                    silent = true
                })}}
            }},
            {n = G.UIT.R, config = {align = "cm", minh = 0.6, maxw = 2.8}, nodes = {
                -- {n = G.UIT.T, config = {id = "selected_deck_name_2", text = texts[2], scale = 0.75/math.max(1,string.len(texts[2])/8), colour = G.C.GREY}},
                {n=G.UIT.O, config = {id = 'deck_name_2', object = DynaText({
                    string = {{ref_table = Galdur.deck_preview_texts, ref_value = 'deck_preview_2'}},
                    scale = 0.7/math.max(1, string.len(Galdur.deck_preview_texts.deck_preview_2)/8),
                    colours = {G.C.GREY},
                    pop_in_rate = 5,
                    silent = true
                })}}
            }},
            {n = G.UIT.R, config = {align = "cm", minh = 0.2}},
                deck_node,
            {n = G.UIT.R, config = {minh = 0.8, align = 'bm'}, nodes = {
                {n = G.UIT.T, config = {text = localize('gald_selected'), scale = 0.75, colour = G.C.GREY}}
            }},
        }}
    }}
end

function Galdur.generate_deck_preview()
    if Galdur.run_setup.selected_deck_area then
        for j=1, #G.I.CARDAREA do
            if Galdur.run_setup.selected_deck_area == G.I.CARDAREA[j] then
                table.remove(G.I.CARDAREA, j)
                Galdur.run_setup.selected_deck_area = nil
            end
        end
    end

    Galdur.run_setup.selected_deck_area = CardArea(15.475, 0, G.CARD_W, G.CARD_H, 
    {card_limit = 52, type = 'deck', highlight_limit = 0, deck_height = 0.15, thin_draw = 1, selected_deck = true})
    Galdur.run_setup.selected_deck_area_holding = CardArea(Galdur.run_setup.selected_deck_area.T.x+2*G.CARD_W, -2*G.CARD_H, G.CARD_W, G.CARD_H, 
    {card_limit = 52, type = 'deck', highlight_limit = 0, deck_height = 0.15, thin_draw = 1, selected_deck = true})
   
end

function Galdur.populate_deck_preview(_deck, silent)
    if Galdur.run_setup.selected_deck_area.cards then
        remove_all(Galdur.run_setup.selected_deck_area.cards)
        Galdur.run_setup.selected_deck_area.cards = {}
        remove_all(Galdur.run_setup.selected_deck_area_holding.cards)
        Galdur.run_setup.selected_deck_area_holding.cards = {} end
    if not _deck then _deck = Back(G.P_CENTERS['b_red']) end

    Galdur.run_setup.selected_deck_height = Galdur.config.reduce and 1 or _deck.effect.center.galdur_height or 52
    for index = 1, Galdur.run_setup.selected_deck_height do
        local card = Card(Galdur.run_setup.selected_deck_area.T.x+2*G.CARD_W, -2*G.CARD_H, G.CARD_W, G.CARD_H,
            _deck.effect.center, _deck.effect.center, {galdur_back = _deck, deck_select = 1, deck_preview = true})
        if Galdur.config.animation and not silent then Galdur.run_setup.selected_deck_area_holding:emplace(card) end
        card.sprite_facing = 'back'
        card.facing = 'back'
        card.children.back = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS[_deck.effect.center.atlas or 'centers'], _deck.effect.center.pos)
        card.children.back.states.hover = card.states.hover
        card.children.back.states.click = card.states.click
        card.children.back.states.drag = card.states.drag
        card.children.back.states.collide.can = false
        card.children.back:set_role({major = card, role_type = 'Glued', draw_major = card})
        if index == Galdur.run_setup.selected_deck_height then
            G.sticker_card = card
            card.sticker = get_deck_win_sticker(_deck.effect.center)
        end
        if silent or not Galdur.config.animation then
            Galdur.run_setup.selected_deck_area:emplace(card)
        elseif index < Galdur.run_setup.selected_deck_height/2 then
            Galdur.run_setup.selected_deck_area:draw_card_from(Galdur.run_setup.selected_deck_area_holding)
        else
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = (function()
                    play_sound('card1', math.random()*0.2 + 0.9, 0.35)
                    if Galdur.run_setup.selected_deck_area_holding.cards and Galdur.run_setup.selected_deck_area.cards then Galdur.run_setup.selected_deck_area:draw_card_from(Galdur.run_setup.selected_deck_area_holding) end
                    return true
                end)
            }), 'galdur')
        end
    end
end

-- Chip Tower Functions
function Galdur.generate_chip_tower()
    if Galdur.run_setup.chip_tower then
        for j=1, #G.I.CARDAREA do
            if Galdur.run_setup.chip_tower == G.I.CARDAREA[j] then
                table.remove(G.I.CARDAREA, j)
                Galdur.run_setup.chip_tower = nil
            end
        end
    end
    Galdur.run_setup.chip_tower = CardArea(G.ROOM.T.w * 0.656, G.ROOM.T.y, 3.4*14/41, 3.4*14/41, 
        {type = 'deck', highlight_limit = 0, draw_layers = {'card'}, thin_draw = 1, stake_chips = true})
    Galdur.run_setup.chip_tower_holding = CardArea(G.ROOM.T.w * 0.656, G.ROOM.T.y, 3.4*14/41, 3.4*14/41, 
        {type = 'deck', highlight_limit = 0, draw_layers = {'card'}, thin_draw = 1, stake_chips = true})
end

function Galdur.populate_chip_tower(_stake, silent)
    if Galdur.run_setup.chip_tower.cards then
        remove_all(Galdur.run_setup.chip_tower.cards)
        Galdur.run_setup.chip_tower.cards = {}
        remove_all(Galdur.run_setup.chip_tower_holding.cards)
        Galdur.run_setup.chip_tower_holding.cards = {}
    end
    if _stake == 0 then _stake = 1 end
    local applied_stakes = order_stake_chain(SMODS.build_stake_chain(G.P_CENTER_POOLS.Stake[_stake]), _stake)
    for index, stake_index in ipairs(applied_stakes) do
        local card = Card(Galdur.run_setup.chip_tower.T.x, G.ROOM.T.y, 3.4*14/41, 3.4*14/41,
            Galdur.run_setup.choices.deck.effect.center, Galdur.run_setup.choices.deck.effect.center,
            {hover = #applied_stakes - index, stake = stake_index, stake_chip = true, chip_tower = true, galdur_selector = true})
        if Galdur.config.animation and not silent then Galdur.run_setup.chip_tower_holding:emplace(card) end
        card.facing = 'back'
        card.sprite_facing = 'back'
        card.children.back = get_stake_sprite_in_area(stake_index, 3.4*14/41, Galdur.run_setup.chip_tower)
        card.children.back.won = true
        card.children.back.states.hover = card.states.hover
        card.children.back.states.click = card.states.click
        card.children.back.states.drag = card.states.drag
        card.children.back.states.collide.can = true
        card.children.back:set_role({major = card, role_type = 'Glued', draw_major = card})
        if Galdur.config.animation and not silent then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.02,
                func = (function()
                    play_sound('chips2', math.random()*0.2 + 0.9, 0.35)
                    if Galdur.run_setup.chip_tower.cards then Galdur.run_setup.chip_tower:draw_card_from(Galdur.run_setup.chip_tower_holding) end
                    return true
                end)
            }), 'galdur')
        else
            Galdur.run_setup.chip_tower:emplace(card)
        end
    end
end

function Galdur.display_chip_tower()
    return
    {n=G.UIT.C, config = {align = "tm", padding = 0.15}, nodes ={
        {n = G.UIT.C, config = {minh = 5.95, minw = 1.5, maxw = 1.5, colour = G.C.BLACK, r=0.1, align = "bm", padding = 0.15, emboss=0.05}, nodes = {
            {n=G.UIT.R, config={align = "cm"}, nodes={
                {n = G.UIT.O, config = {object = Galdur.run_setup.chip_tower}}
            }}
        }}
    }}
end

function order_stake_chain(stake_chain, _stake)
    local ordered_chain = {}
    for i,_ in ipairs(G.P_CENTER_POOLS.Stake) do
        if stake_chain[i] and i~= _stake then
            ordered_chain[#ordered_chain+1] = i
        end
    end
    ordered_chain[#ordered_chain+1] = _stake
    return ordered_chain
end

-- Util Functions
function split_string_2(_string)
    local length = string.len(_string)
    local split = {}
    for i in string.gmatch(_string, "%S+") do
        table.insert(split, i)
    end
    local words = #split
    local spaces = words - 1
    local mid = math.ceil(length * 0.4)
    
    local text_output = {"", ""}
    for i,v in ipairs(split) do
        if string.len(text_output[1]) > mid or i > spaces then
            text_output[2] = text_output[2] .. v .. " "
        else
            text_output[1] = text_output[1] .. v .. " "
        end
    end
    text_output[1] = string.sub(text_output[1], 1, string.len(text_output[1])-1)
    text_output[2] = string.sub(text_output[2], 1, string.len(text_output[2])-1)
    return text_output
end

function create_stake_unlock_message(stake)
    local number_applied_stakes = #stake.applied_stakes
    local string_output = localize('gald_unlock_1')
    for i,v in ipairs(stake.applied_stakes) do
        string_output = string_output .. localize({type='name_text', set='Stake', key='stake_'..v}) .. (i < number_applied_stakes and localize('gald_unlock_and') or '')
    end
    local split = split_string_2(string_output)

    return {
        {n=G.UIT.R, config={align='cm'}, nodes={
            {n=G.UIT.T, config={text = split[1], scale = 0.3, colour = G.C.UI.TEXT_DARK}}
        }},
        {n=G.UIT.R, config={align='cm'}, nodes={
            {n=G.UIT.T, config={text = split[2], scale = 0.3, colour = G.C.UI.TEXT_DARK}}
        }}
    }
end

function populate_info_queue(set, key)
    local info_queue = {}
    local loc_target = G.localization.descriptions[set][key]
    for _, lines in ipairs(loc_target.text_parsed) do
        for _, part in ipairs(lines) do
            if part.control.T then info_queue[#info_queue+1] = G.P_CENTERS[part.control.T] or G.P_TAGS[part.control.T] end
        end
    end
    return info_queue
end

function Galdur.spit(message)
    sendDebugMessage(message, "Galdur")
end

-- Function Overrides
function G.FUNCS.toggle_seeded_run_galdur(bool, e)
    if not e then return end
    local current_selector_page = e.UIBox:get_UIE_by_ID('seed_input')
    local seed_unlocker_present = (SMODS.Mods['SeedUnlocker'] or {}).can_load
    if not current_selector_page then return end
    current_selector_page.config.object:remove()
    current_selector_page.config.object = bool and UIBox{
        definition = {n=G.UIT.ROOT, config={align = "cr", colour = G.C.CLEAR}, nodes={
          {n=G.UIT.C, config={align = "cm", minw = 2.5, padding = 0.05}, nodes={
            simple_text_container('ml_disabled_seed',{colour = G.C.UI.TEXT_LIGHT, scale = 0.26, shadow = true}),
          }},
          {n=G.UIT.C, config={align = "cm", minw = 0.1}, nodes={
            {n=G.UIT.C, config={maxw = 3.1}, nodes = {
                seed_unlocker_present and
                create_text_input({max_length = 2500, extended_corpus = true, ref_table = Galdur.run_setup.choices, ref_value = 'seed', prompt_text = localize('k_enter_seed')})
             or create_text_input({max_length = 8, all_caps = true, ref_table = Galdur.run_setup.choices, ref_value = 'seed', prompt_text = localize('k_enter_seed')}),
            }},
            {n=G.UIT.C, config={align = "cm", minw = 0.1}, nodes={}},
            UIBox_button({label = localize('ml_paste_seed'),minw = 1, minh = 0.6, button = 'paste_seed', colour = G.C.BLUE, scale = 0.3, col = true})
          }}
        }},
        config = {offset = {x=0,y=0}, parent = e, type = 'cm'}
    } or Moveable()
    if Galdur.run_setup.choices.seed_select then current_selector_page.UIBox:recalculate() end
end

function G.FUNCS.toggle_button(e)
    local ref = e.config.ref_table
    ref.ref_table[ref.ref_value] = not ref.ref_table[ref.ref_value]
    if e.config.toggle_callback then 
        e.config.toggle_callback(ref.ref_table[ref.ref_value], e) -- pass the node it's from too
    end
end

-- Testing objects
if Galdur.test_mode then
    for i=1, 10 do
        SMODS.Stake({
            key = "test_"..i,
            applied_stakes = i==1 and {} or {"galdur_test_"..(i-1)},
            above_stake = (i==1 and 'red' or "galdur_test_"..(i-1)),
            loc_txt = {
                name = "Test Stake "..i,
                text = {
                "Required score scales",
                "faster for each {C:attention}Ante"
                }
            },
            pos = {x = 3, y = 1},
            shiny = true,
            sticker_pos = {x = 1, y = 0},
            sticker_atlas = 'sticker'
        })
        -- SMODS.Back({
        --     key = "test_"..i
        -- })
    end

    SMODS.Stake:take_ownership('blue', {
        applied_stakes = {"galdur_test_2"},
        loc_txt = {
            name = "Apple Stake",
            text = {
            "Required score scales",
            "faster for each {C:attention}Ante"
            }
        },
    })

    SMODS.Atlas({
        key = 'sticker',
        path = 'stickers.png',
        px = 71,
        py = 95
    })

    SMODS.Stake({
        key = "test_stake",
        applied_stakes = {"cry_brown", "galdur_test_10"},
        above_stake = ('galdur_test_10'),
        pos = { x = 4, y = 1 },
        loc_txt = {
            name = "Test Stake FINAL",
            text = {
            "Required {T:m_wild}score {T:e_foil}scales",
            "faster for {T:j_jolly}each {C:attention}Ante"
            }
        },
        sticker_pos = {x = 1, y = 0},
        sticker_atlas = 'sticker',
        shiny = true
    })
end
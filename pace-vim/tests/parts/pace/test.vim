""""""""""""""""""""""""""""""""""|test.vim|""""""""""""""""""""""""""""""""""
" Also see {enter,load}.vim.

let s:cpoptions = &cpoptions
set cpoptions-=C					" Join line-breaks.

let s:pace.dump = {'0': [[0, 0, 0, 0]]}

try
	let s:test_mode = s:mockup.mode
	call s:Assert_Not_Equal(1, 'i', s:mockup.mode)
	call s:Assert_Equal(501, 0, s:pace.carry)	" second parts
	call s:Assert_Equal(502, 0, s:Get_Parts())	" second parts
	let s:test_1 = s:Pace_Load(1)
	let s:insertmode = 'i'
	let s:mockup.mode = 'i'


	unlet! g:pace_policy
	let g:pace_policy = 10007

	call s:Assert_True(1, !exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(1, -1, s:Get_Chars())
	call s:Assert_True(2, exists('#pace'))
	call s:Assert_True(3, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		" 0/1 [log_hits/all_hits]
	call s:Assert_Equal(2, 0, s:Get_Chars())
	call s:Assert_True(4, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	call s:Assert_Equal(3, 2, s:Get_Chars())
	call s:Assert_True(5, exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(503, 0, s:pace.carry)
	call s:Assert_Equal(504, 2, s:Get_Parts())
	doautocmd pace InsertLeave		" 1/1: Update the count.
	call s:Assert_Equal(505, 2, s:pace.carry)
	call s:Assert_Equal(506, 2, s:Get_Parts())
	call s:Assert_Equal(4, 2, s:pace.dump[0][0][2])
	call s:Assert_Equal(5, s:pace.dump[0][0][0], s:pace.dump[0][0][1])

	call s:Assert_True(6, !exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(6, -1, s:Get_Chars())
	call s:Assert_True(7, exists('#pace'))
	call s:Assert_True(8, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		" 1/2
	call s:Assert_Equal(7, 0, s:Get_Chars())
	call s:Assert_True(9, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		" 1/2: Discard null.
	call s:Assert_Equal(507, 2, s:pace.carry)
	call s:Assert_Equal(508, 2, s:Get_Parts())
	call s:Assert_Equal(8, 0x10000, and(s:pace.policy, 0x10100))
	call s:Assert_Equal(9, 2, s:pace.dump[0][0][2])
	call s:Assert_Equal(10, (s:pace.dump[0][0][0] + 1),
						\ s:pace.dump[0][0][1])

	call s:Assert_True(10, !exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(11, 0, s:Get_Chars())
	call s:Assert_True(11, exists('#pace'))
	call s:Assert_True(12, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		" 1/3
	call s:Assert_Equal(12, 0, s:Get_Chars())
	call s:Assert_True(13, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	call s:Assert_Equal(13, 2, s:Get_Chars())
	call s:Assert_True(14, exists('#pace#InsertEnter#*'))
	call s:Assert_Equal(509, 2, s:pace.carry)
	call s:Assert_Equal(510, 4, s:Get_Parts())
	doautocmd pace InsertEnter		" 1/4: Discard rejects.
	call s:Assert_Equal(511, 2, s:pace.carry)
	call s:Assert_Equal(512, 2, s:Get_Parts())
	call s:Assert_Equal(14, 0x10000, and(s:pace.policy, 0x10030))
	call s:Assert_Equal(15, 2, s:pace.dump[0][0][2])
	call s:Assert_Equal(16, (s:pace.dump[0][0][0] + 3),
						\ s:pace.dump[0][0][1])
	call s:Assert_True(15, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		" 1/4: Discard null.
	call s:Assert_Equal(513, 2, s:pace.carry)
	call s:Assert_Equal(514, 2, s:Get_Parts())
	call s:Assert_Equal(17, (s:pace.dump[0][0][0] + 3),
						\ s:pace.dump[0][0][1])


	unlet! g:pace_policy
	let g:pace_policy = 10017

	call s:Assert_True(16, !exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(18, 0, s:Get_Chars())
	call s:Assert_True(17, exists('#pace'))
	call s:Assert_True(18, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		" 1/5
	call s:Assert_Equal(19, 0, s:Get_Chars())
	call s:Assert_True(19, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	call s:Assert_Equal(20, 2, s:Get_Chars())
	call s:Assert_True(20, exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(515, 2, s:pace.carry)
	call s:Assert_Equal(516, 4, s:Get_Parts())
	doautocmd pace InsertLeave		" 2/5: Update the count.
	call s:Assert_Equal(517, 4, s:pace.carry)
	call s:Assert_Equal(518, 4, s:Get_Parts())
	call s:Assert_Equal(21, 4, s:pace.dump[0][0][2])
	call s:Assert_Equal(22, (s:pace.dump[0][0][0] + 3),
						\ s:pace.dump[0][0][1])

	call s:Assert_True(21, !exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(23, -1, s:Get_Chars())
	call s:Assert_True(22, exists('#pace'))
	call s:Assert_True(23, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		" 2/6
	call s:Assert_Equal(24, 0, s:Get_Chars())
	call s:Assert_True(24, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		" 2/6: Discard null.
	call s:Assert_Equal(519, 4, s:pace.carry)
	call s:Assert_Equal(520, 4, s:Get_Parts())
	call s:Assert_Equal(25, 0x10000, and(s:pace.policy, 0x10100))
	call s:Assert_Equal(26, 4, s:pace.dump[0][0][2])
	call s:Assert_Equal(27, (s:pace.dump[0][0][0] + 4),
						\ s:pace.dump[0][0][1])

	call s:Assert_True(25, !exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(28, 0, s:Get_Chars())
	call s:Assert_True(26, exists('#pace'))
	call s:Assert_True(27, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		" 2/7
	call s:Assert_Equal(29, 0, s:Get_Chars())
	call s:Assert_True(28, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	call s:Assert_Equal(30, 2, s:Get_Chars())
	call s:Assert_True(29, exists('#pace#InsertEnter#*'))
	call s:Assert_Equal(521, 4, s:pace.carry)
	call s:Assert_Equal(522, 6, s:Get_Parts())
	doautocmd pace InsertEnter		" 3/8: Keep rejects.
	call s:Assert_Equal(523, 6, s:pace.carry)
	call s:Assert_Equal(524, 6, s:Get_Parts())
	call s:Assert_Equal(31, 0x10010, and(s:pace.policy, 0x10010))
	call s:Assert_Equal(32, 6, s:pace.dump[0][0][2])
	call s:Assert_Equal(33, (s:pace.dump[0][0][0] + 5),
						\ s:pace.dump[0][0][1])
	call s:Assert_True(30, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		" 3/8: Discard null.
	call s:Assert_Equal(525, 6, s:pace.carry)
	call s:Assert_Equal(526, 6, s:Get_Parts())
	call s:Assert_Equal(34, (s:pace.dump[0][0][0] + 5),
						\ s:pace.dump[0][0][1])


	unlet! g:pace_policy
	let g:pace_policy = 10027

	call s:Assert_True(31, !exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(35, 0, s:Get_Chars())
	call s:Assert_True(32, exists('#pace'))
	call s:Assert_True(33, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		" 3/9
	call s:Assert_Equal(36, 0, s:Get_Chars())
	call s:Assert_True(34, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	call s:Assert_Equal(37, 2, s:Get_Chars())
	call s:Assert_True(35, exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(527, 6, s:pace.carry)
	call s:Assert_Equal(528, 8, s:Get_Parts())
	doautocmd pace InsertLeave		" 4/9: Update the count.
	call s:Assert_Equal(529, 8, s:pace.carry)
	call s:Assert_Equal(530, 8, s:Get_Parts())
	call s:Assert_Equal(38, 8, s:pace.dump[0][0][2])
	call s:Assert_Equal(39, (s:pace.dump[0][0][0] + 5),
						\ s:pace.dump[0][0][1])

	call s:Assert_True(36, !exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(40, -1, s:Get_Chars())
	call s:Assert_True(37, exists('#pace'))
	call s:Assert_True(38, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		" 4/10
	call s:Assert_Equal(41, 0, s:Get_Chars())
	call s:Assert_True(39, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		" 4/10: Discard null.
	call s:Assert_Equal(531, 8, s:pace.carry)
	call s:Assert_Equal(532, 8, s:Get_Parts())
	call s:Assert_Equal(42, 0x10000, and(s:pace.policy, 0x10100))
	call s:Assert_Equal(43, 8, s:pace.dump[0][0][2])
	call s:Assert_Equal(44, (s:pace.dump[0][0][0] + 6),
						\ s:pace.dump[0][0][1])

	call s:Assert_True(40, !exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(45, 0, s:Get_Chars())
	call s:Assert_True(41, exists('#pace'))
	call s:Assert_True(42, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		" 4/11
	call s:Assert_Equal(46, 0, s:Get_Chars())
	call s:Assert_True(43, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	call s:Assert_Equal(47, 2, s:Get_Chars())
	call s:Assert_True(44, exists('#pace#InsertEnter#*'))
	call s:Assert_Equal(533, 8, s:pace.carry)
	call s:Assert_Equal(534, 10, s:Get_Parts())
	doautocmd pace InsertEnter		" 5/12: Mark rejects.
	call s:Assert_Equal(535, 10, s:pace.carry)
	call s:Assert_Equal(536, 10, s:Get_Parts())
	call s:Assert_Equal(48, 0x10020, and(s:pace.policy, 0x10020))
	call s:Assert_Equal(49, 10, s:pace.dump[0][0][2])
	call s:Assert_Equal(50, (s:pace.dump[0][0][0] + 7),
						\ s:pace.dump[0][0][1])
	call s:Assert_True(45, s:pace.dump[bufnr('%')][-1][0] < 0)
	call s:Assert_True(46, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		" 5/12: Discard null.
	call s:Assert_Equal(537, 10, s:pace.carry)
	call s:Assert_Equal(538, 10, s:Get_Parts())
	call s:Assert_Equal(51, (s:pace.dump[0][0][0] + 7),
						\ s:pace.dump[0][0][1])


	unlet! g:pace_policy
	let g:pace_policy = 10107

	call s:Assert_True(47, !exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(52, 0, s:Get_Chars())
	call s:Assert_True(48, exists('#pace'))
	call s:Assert_True(49, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		" 5/13
	call s:Assert_Equal(53, 0, s:Get_Chars())
	call s:Assert_True(50, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	call s:Assert_Equal(54, 2, s:Get_Chars())
	call s:Assert_True(51, exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(539, 10, s:pace.carry)
	call s:Assert_Equal(540, 12, s:Get_Parts())
	doautocmd pace InsertLeave		" 6/13: Update the count.
	call s:Assert_Equal(541, 12, s:pace.carry)
	call s:Assert_Equal(542, 12, s:Get_Parts())
	call s:Assert_Equal(55, 12, s:pace.dump[0][0][2])
	call s:Assert_Equal(56, (s:pace.dump[0][0][0] + 7),
						\ s:pace.dump[0][0][1])

	call s:Assert_True(52, !exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(57, -1, s:Get_Chars())
	call s:Assert_True(53, exists('#pace'))
	call s:Assert_True(54, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		" 6/14
	call s:Assert_Equal(58, 0, s:Get_Chars())
	call s:Assert_True(55, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		" 7/14: Keep null.
	call s:Assert_Equal(543, 12, s:pace.carry)
	call s:Assert_Equal(544, 12, s:Get_Parts())
	call s:Assert_Equal(59, 0x10100, and(s:pace.policy, 0x10100))
	call s:Assert_Equal(60, 12, s:pace.dump[0][0][2])
	call s:Assert_Equal(61, (s:pace.dump[0][0][0] + 7),
						\ s:pace.dump[0][0][1])

	call s:Assert_True(56, !exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(62, -1, s:Get_Chars())
	call s:Assert_True(57, exists('#pace'))
	call s:Assert_True(58, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		" 7/15
	call s:Assert_Equal(63, 0, s:Get_Chars())
	call s:Assert_True(59, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	call s:Assert_Equal(64, 2, s:Get_Chars())
	call s:Assert_True(60, exists('#pace#InsertEnter#*'))
	call s:Assert_Equal(545, 12, s:pace.carry)
	call s:Assert_Equal(546, 14, s:Get_Parts())
	doautocmd pace InsertEnter		" 7/16: Discard rejects.
	call s:Assert_Equal(547, 12, s:pace.carry)
	call s:Assert_Equal(548, 12, s:Get_Parts())
	call s:Assert_Equal(65, 0x10000, and(s:pace.policy, 0x10030))
	call s:Assert_Equal(66, 12, s:pace.dump[0][0][2])
	call s:Assert_Equal(67, (s:pace.dump[0][0][0] + 9),
						\ s:pace.dump[0][0][1])
	call s:Assert_True(61, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		" 8/16: Keep null.
	call s:Assert_Equal(549, 12, s:pace.carry)
	call s:Assert_Equal(550, 12, s:Get_Parts())
	call s:Assert_Equal(68, (s:pace.dump[0][0][0] + 8),
						\ s:pace.dump[0][0][1])


	unlet! g:pace_policy
	let g:pace_policy = 10117

	call s:Assert_True(62, !exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(69, -1, s:Get_Chars())
	call s:Assert_True(63, exists('#pace'))
	call s:Assert_True(64, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		" 8/17
	call s:Assert_Equal(70, 0, s:Get_Chars())
	call s:Assert_True(65, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	call s:Assert_Equal(71, 2, s:Get_Chars())
	call s:Assert_True(66, exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(551, 12, s:pace.carry)
	call s:Assert_Equal(552, 14, s:Get_Parts())
	doautocmd pace InsertLeave		" 9/17: Update the count.
	call s:Assert_Equal(553, 14, s:pace.carry)
	call s:Assert_Equal(554, 14, s:Get_Parts())
	call s:Assert_Equal(72, 14, s:pace.dump[0][0][2])
	call s:Assert_Equal(73, (s:pace.dump[0][0][0] + 8),
						\ s:pace.dump[0][0][1])

	call s:Assert_True(67, !exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(74, -1, s:Get_Chars())
	call s:Assert_True(68, exists('#pace'))
	call s:Assert_True(69, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		" 9/18
	call s:Assert_Equal(75, 0, s:Get_Chars())
	call s:Assert_True(70, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		" 10/18: Keep null.
	call s:Assert_Equal(555, 14, s:pace.carry)
	call s:Assert_Equal(556, 14, s:Get_Parts())
	call s:Assert_Equal(76, 0x10100, and(s:pace.policy, 0x10100))
	call s:Assert_Equal(77, 14, s:pace.dump[0][0][2])
	call s:Assert_Equal(78, (s:pace.dump[0][0][0] + 8),
						\ s:pace.dump[0][0][1])

	call s:Assert_True(71, !exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(79, -1, s:Get_Chars())
	call s:Assert_True(72, exists('#pace'))
	call s:Assert_True(73, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		" 10/19
	call s:Assert_Equal(80, 0, s:Get_Chars())
	call s:Assert_True(74, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	call s:Assert_Equal(81, 2, s:Get_Chars())
	call s:Assert_True(75, exists('#pace#InsertEnter#*'))
	call s:Assert_Equal(557, 14, s:pace.carry)
	call s:Assert_Equal(558, 16, s:Get_Parts())
	doautocmd pace InsertEnter		" 11/20: Keep rejects.
	call s:Assert_Equal(559, 16, s:pace.carry)
	call s:Assert_Equal(560, 16, s:Get_Parts())
	call s:Assert_Equal(82, 0x10010, and(s:pace.policy, 0x10010))
	call s:Assert_Equal(83, 16, s:pace.dump[0][0][2])
	call s:Assert_Equal(84, (s:pace.dump[0][0][0] + 9),
						\ s:pace.dump[0][0][1])
	call s:Assert_True(76, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		" 12/20: Keep null.
	call s:Assert_Equal(561, 16, s:pace.carry)
	call s:Assert_Equal(562, 16, s:Get_Parts())
	call s:Assert_Equal(85, (s:pace.dump[0][0][0] + 8),
						\ s:pace.dump[0][0][1])


	unlet! g:pace_policy
	let g:pace_policy = 10127

	call s:Assert_True(77, !exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(86, -1, s:Get_Chars())
	call s:Assert_True(78, exists('#pace'))
	call s:Assert_True(79, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		" 12/21
	call s:Assert_Equal(87, 0, s:Get_Chars())
	call s:Assert_True(80, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	call s:Assert_Equal(88, 2, s:Get_Chars())
	call s:Assert_True(81, exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(563, 16, s:pace.carry)
	call s:Assert_Equal(564, 18, s:Get_Parts())
	doautocmd pace InsertLeave		" 13/21: Update the count.
	call s:Assert_Equal(565, 18, s:pace.carry)
	call s:Assert_Equal(566, 18, s:Get_Parts())
	call s:Assert_Equal(89, 18, s:pace.dump[0][0][2])
	call s:Assert_Equal(90, (s:pace.dump[0][0][0] + 8),
						\ s:pace.dump[0][0][1])

	call s:Assert_True(82, !exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(91, -1, s:Get_Chars())
	call s:Assert_True(83, exists('#pace'))
	call s:Assert_True(84, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		" 13/22
	call s:Assert_Equal(92, 0, s:Get_Chars())
	call s:Assert_True(85, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		" 14/22: Keep null.
	call s:Assert_Equal(567, 18, s:pace.carry)
	call s:Assert_Equal(568, 18, s:Get_Parts())
	call s:Assert_Equal(93, 0x10100, and(s:pace.policy, 0x10100))
	call s:Assert_Equal(94, 18, s:pace.dump[0][0][2])
	call s:Assert_Equal(95, (s:pace.dump[0][0][0] + 8),
						\ s:pace.dump[0][0][1])

	call s:Assert_True(86, !exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(96, -1, s:Get_Chars())
	call s:Assert_True(87, exists('#pace'))
	call s:Assert_True(88, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		" 14/23
	call s:Assert_Equal(97, 0, s:Get_Chars())
	call s:Assert_True(89, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	call s:Assert_Equal(98, 2, s:Get_Chars())
	call s:Assert_True(90, exists('#pace#InsertEnter#*'))
	call s:Assert_Equal(569, 18, s:pace.carry)
	call s:Assert_Equal(570, 20, s:Get_Parts())
	doautocmd pace InsertEnter		" 15/24: Mark rejects.
	call s:Assert_Equal(571, 20, s:pace.carry)
	call s:Assert_Equal(572, 20, s:Get_Parts())
	call s:Assert_Equal(99, 0x10020, and(s:pace.policy, 0x10020))
	call s:Assert_Equal(100, 20, s:pace.dump[0][0][2])
	call s:Assert_Equal(101, (s:pace.dump[0][0][0] + 9),
						\ s:pace.dump[0][0][1])
	call s:Assert_True(91, s:pace.dump[bufnr('%')][-1][0] < 0)
	call s:Assert_True(92, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		" 16/24: Keep null.
	call s:Assert_Equal(573, 20, s:pace.carry)
	call s:Assert_Equal(574, 20, s:Get_Parts())
	call s:Assert_Equal(102, (s:pace.dump[0][0][0] + 8),
						\ s:pace.dump[0][0][1])
	let s:mockup.mode = 'n'
	let s:test_2 = s:Pace_Load(0)

	let s:test_3 = s:Pace_Load(1)
	let s:mockup.mode = 'i'
	let s:test_updatetime = &updatetime
	let &updatetime = s:pace.sample.above - 2 * s:pace.sample.below
	unlet! g:pace_sample
	call s:Assert_True(93, s:pace.sample.in < s:pace.sample.below)

	try
		let g:pace_sample = s:pace.sample.above - s:pace.sample.below
		let s:test_sample_in = s:pace.sample.in
		doautocmd pace InsertEnter
		call s:Assert_Not_Equal(2, s:pace.sample.in, s:test_sample_in)
		call s:Assert_Not_Equal(3, &updatetime, s:pace.state.updatetime)
		call s:Assert_Equal(103, &updatetime, s:pace.sample.in)

		let g:pace_sample = s:pace.sample.above + 1
		let s:test_sample_in = s:pace.sample.in
		doautocmd pace InsertEnter
		call s:Assert_Not_Equal(4, s:pace.sample.in, s:test_sample_in)
		call s:Assert_Not_Equal(5, &updatetime, s:pace.sample.in)
		call s:Assert_Equal(104, &updatetime, s:pace.state.updatetime)

		let g:pace_sample = s:pace.sample.below - 1
		let s:test_sample_in = s:pace.sample.in
		doautocmd pace InsertEnter
		call s:Assert_Not_Equal(6, s:pace.sample.in, s:test_sample_in)
		call s:Assert_Not_Equal(7, &updatetime, s:pace.sample.in)
		call s:Assert_Equal(105, &updatetime, s:pace.state.updatetime)

		let g:pace_sample = s:pace.sample.above - s:pace.sample.below
		let s:test_sample_in = s:pace.sample.in
		doautocmd pace InsertEnter
		call s:Assert_Not_Equal(8, s:pace.sample.in, s:test_sample_in)
		call s:Assert_Not_Equal(9, &updatetime, s:pace.state.updatetime)
		call s:Assert_Equal(106, &updatetime, s:pace.sample.in)

		let g:pace_sample = s:pace.sample.above - 2 * s:pace.sample.below
		let s:test_sample_in = s:pace.sample.in
		doautocmd pace InsertEnter
		call s:Assert_Not_Equal(10, s:pace.sample.in, s:test_sample_in)
		call s:Assert_Not_Equal(11, &updatetime, s:pace.state.updatetime)
		call s:Assert_Equal(107, &updatetime, s:pace.sample.in)
	finally
		let &updatetime = s:test_updatetime
	endtry

	let s:mockup.mode = 'n'
	let s:test_4 = s:Pace_Load(0)
finally
	let s:mockup.mode = s:test_mode
endtry

let &cpoptions = s:cpoptions
unlet s:cpoptions
quit
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""

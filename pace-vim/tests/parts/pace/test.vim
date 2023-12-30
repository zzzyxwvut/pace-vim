##################################|test.vim|##################################
# Also see {enter,load}.vim.
pace.dump = {'0': [[0, 0, 0, 0]]}
const test_mode: string = mockup.mode

try
	Assert_Not_Equal(1, 'i', mockup.mode)
	Assert_Equal(501, 0, pace.carry)		# second parts
	Assert_Equal(502, 0, Get_Parts())		# second parts
	const test_1: number = Pace_Load(1)
	insertmode = 'i'
	mockup.mode = 'i'


	unlet! g:pace_policy
	g:pace_policy = 10007

	Assert_True(1, !exists('#pace#InsertLeave#*'))
	Assert_Equal(1, -1, Get_Chars())
	Assert_True(2, exists('#pace'))
	Assert_True(3, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		# 0/1 [log_hits/all_hits]
	Assert_Equal(2, 0, Get_Chars())
	Assert_True(4, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	Assert_Equal(3, 2, Get_Chars())
	Assert_True(5, exists('#pace#InsertLeave#*'))
	Assert_Equal(503, 0, pace.carry)
	Assert_Equal(504, 2, Get_Parts())
	doautocmd pace InsertLeave		# 1/1: Update the count.
	Assert_Equal(505, 2, pace.carry)
	Assert_Equal(506, 2, Get_Parts())
	Assert_Equal(4, 2, pace.dump[0][0][2])
	Assert_Equal(5, pace.dump[0][0][0], pace.dump[0][0][1])

	Assert_True(6, !exists('#pace#InsertLeave#*'))
	Assert_Equal(6, -1, Get_Chars())
	Assert_True(7, exists('#pace'))
	Assert_True(8, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		# 1/2
	Assert_Equal(7, 0, Get_Chars())
	Assert_True(9, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		# 1/2: Discard null.
	Assert_Equal(507, 2, pace.carry)
	Assert_Equal(508, 2, Get_Parts())
	Assert_Equal(8, 0x10000, and(pace.policy, 0x10100))
	Assert_Equal(9, 2, pace.dump[0][0][2])
	Assert_Equal(10, (pace.dump[0][0][0] + 1), pace.dump[0][0][1])

	Assert_True(10, !exists('#pace#InsertLeave#*'))
	Assert_Equal(11, 0, Get_Chars())
	Assert_True(11, exists('#pace'))
	Assert_True(12, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		# 1/3
	Assert_Equal(12, 0, Get_Chars())
	Assert_True(13, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	Assert_Equal(13, 2, Get_Chars())
	Assert_True(14, exists('#pace#InsertEnter#*'))
	Assert_Equal(509, 2, pace.carry)
	Assert_Equal(510, 4, Get_Parts())
	doautocmd pace InsertEnter		# 1/4: Discard rejects.
	Assert_Equal(511, 2, pace.carry)
	Assert_Equal(512, 2, Get_Parts())
	Assert_Equal(14, 0x10000, and(pace.policy, 0x10030))
	Assert_Equal(15, 2, pace.dump[0][0][2])
	Assert_Equal(16, (pace.dump[0][0][0] + 3), pace.dump[0][0][1])
	Assert_True(15, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		# 1/4: Discard null.
	Assert_Equal(513, 2, pace.carry)
	Assert_Equal(514, 2, Get_Parts())
	Assert_Equal(17, (pace.dump[0][0][0] + 3), pace.dump[0][0][1])


	unlet! g:pace_policy
	g:pace_policy = 10017

	Assert_True(16, !exists('#pace#InsertLeave#*'))
	Assert_Equal(18, 0, Get_Chars())
	Assert_True(17, exists('#pace'))
	Assert_True(18, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		# 1/5
	Assert_Equal(19, 0, Get_Chars())
	Assert_True(19, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	Assert_Equal(20, 2, Get_Chars())
	Assert_True(20, exists('#pace#InsertLeave#*'))
	Assert_Equal(515, 2, pace.carry)
	Assert_Equal(516, 4, Get_Parts())
	doautocmd pace InsertLeave		# 2/5: Update the count.
	Assert_Equal(517, 4, pace.carry)
	Assert_Equal(518, 4, Get_Parts())
	Assert_Equal(21, 4, pace.dump[0][0][2])
	Assert_Equal(22, (pace.dump[0][0][0] + 3), pace.dump[0][0][1])

	Assert_True(21, !exists('#pace#InsertLeave#*'))
	Assert_Equal(23, -1, Get_Chars())
	Assert_True(22, exists('#pace'))
	Assert_True(23, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		# 2/6
	Assert_Equal(24, 0, Get_Chars())
	Assert_True(24, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		# 2/6: Discard null.
	Assert_Equal(519, 4, pace.carry)
	Assert_Equal(520, 4, Get_Parts())
	Assert_Equal(25, 0x10000, and(pace.policy, 0x10100))
	Assert_Equal(26, 4, pace.dump[0][0][2])
	Assert_Equal(27, (pace.dump[0][0][0] + 4), pace.dump[0][0][1])

	Assert_True(25, !exists('#pace#InsertLeave#*'))
	Assert_Equal(28, 0, Get_Chars())
	Assert_True(26, exists('#pace'))
	Assert_True(27, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		# 2/7
	Assert_Equal(29, 0, Get_Chars())
	Assert_True(28, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	Assert_Equal(30, 2, Get_Chars())
	Assert_True(29, exists('#pace#InsertEnter#*'))
	Assert_Equal(521, 4, pace.carry)
	Assert_Equal(522, 6, Get_Parts())
	doautocmd pace InsertEnter		# 3/8: Keep rejects.
	Assert_Equal(523, 6, pace.carry)
	Assert_Equal(524, 6, Get_Parts())
	Assert_Equal(31, 0x10010, and(pace.policy, 0x10010))
	Assert_Equal(32, 6, pace.dump[0][0][2])
	Assert_Equal(33, (pace.dump[0][0][0] + 5), pace.dump[0][0][1])
	Assert_True(30, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		# 3/8: Discard null.
	Assert_Equal(525, 6, pace.carry)
	Assert_Equal(526, 6, Get_Parts())
	Assert_Equal(34, (pace.dump[0][0][0] + 5), pace.dump[0][0][1])


	unlet! g:pace_policy
	g:pace_policy = 10027

	Assert_True(31, !exists('#pace#InsertLeave#*'))
	Assert_Equal(35, 0, Get_Chars())
	Assert_True(32, exists('#pace'))
	Assert_True(33, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		# 3/9
	Assert_Equal(36, 0, Get_Chars())
	Assert_True(34, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	Assert_Equal(37, 2, Get_Chars())
	Assert_True(35, exists('#pace#InsertLeave#*'))
	Assert_Equal(527, 6, pace.carry)
	Assert_Equal(528, 8, Get_Parts())
	doautocmd pace InsertLeave		# 4/9: Update the count.
	Assert_Equal(529, 8, pace.carry)
	Assert_Equal(530, 8, Get_Parts())
	Assert_Equal(38, 8, pace.dump[0][0][2])
	Assert_Equal(39, (pace.dump[0][0][0] + 5), pace.dump[0][0][1])

	Assert_True(36, !exists('#pace#InsertLeave#*'))
	Assert_Equal(40, -1, Get_Chars())
	Assert_True(37, exists('#pace'))
	Assert_True(38, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		# 4/10
	Assert_Equal(41, 0, Get_Chars())
	Assert_True(39, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		# 4/10: Discard null.
	Assert_Equal(531, 8, pace.carry)
	Assert_Equal(532, 8, Get_Parts())
	Assert_Equal(42, 0x10000, and(pace.policy, 0x10100))
	Assert_Equal(43, 8, pace.dump[0][0][2])
	Assert_Equal(44, (pace.dump[0][0][0] + 6), pace.dump[0][0][1])

	Assert_True(40, !exists('#pace#InsertLeave#*'))
	Assert_Equal(45, 0, Get_Chars())
	Assert_True(41, exists('#pace'))
	Assert_True(42, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		# 4/11
	Assert_Equal(46, 0, Get_Chars())
	Assert_True(43, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	Assert_Equal(47, 2, Get_Chars())
	Assert_True(44, exists('#pace#InsertEnter#*'))
	Assert_Equal(533, 8, pace.carry)
	Assert_Equal(534, 10, Get_Parts())
	doautocmd pace InsertEnter		# 5/12: Mark rejects.
	Assert_Equal(535, 10, pace.carry)
	Assert_Equal(536, 10, Get_Parts())
	Assert_Equal(48, 0x10020, and(pace.policy, 0x10020))
	Assert_Equal(49, 10, pace.dump[0][0][2])
	Assert_Equal(50, (pace.dump[0][0][0] + 7), pace.dump[0][0][1])
	Assert_True(45, pace.dump[bufnr('%')][-1][0] < 0)
	Assert_True(46, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		# 5/12: Discard null.
	Assert_Equal(537, 10, pace.carry)
	Assert_Equal(538, 10, Get_Parts())
	Assert_Equal(51, (pace.dump[0][0][0] + 7), pace.dump[0][0][1])


	unlet! g:pace_policy
	g:pace_policy = 10107

	Assert_True(47, !exists('#pace#InsertLeave#*'))
	Assert_Equal(52, 0, Get_Chars())
	Assert_True(48, exists('#pace'))
	Assert_True(49, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		# 5/13
	Assert_Equal(53, 0, Get_Chars())
	Assert_True(50, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	Assert_Equal(54, 2, Get_Chars())
	Assert_True(51, exists('#pace#InsertLeave#*'))
	Assert_Equal(539, 10, pace.carry)
	Assert_Equal(540, 12, Get_Parts())
	doautocmd pace InsertLeave		# 6/13: Update the count.
	Assert_Equal(541, 12, pace.carry)
	Assert_Equal(542, 12, Get_Parts())
	Assert_Equal(55, 12, pace.dump[0][0][2])
	Assert_Equal(56, (pace.dump[0][0][0] + 7), pace.dump[0][0][1])

	Assert_True(52, !exists('#pace#InsertLeave#*'))
	Assert_Equal(57, -1, Get_Chars())
	Assert_True(53, exists('#pace'))
	Assert_True(54, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		# 6/14
	Assert_Equal(58, 0, Get_Chars())
	Assert_True(55, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		# 7/14: Keep null.
	Assert_Equal(543, 12, pace.carry)
	Assert_Equal(544, 12, Get_Parts())
	Assert_Equal(59, 0x10100, and(pace.policy, 0x10100))
	Assert_Equal(60, 12, pace.dump[0][0][2])
	Assert_Equal(61, (pace.dump[0][0][0] + 7), pace.dump[0][0][1])

	Assert_True(56, !exists('#pace#InsertLeave#*'))
	Assert_Equal(62, -1, Get_Chars())
	Assert_True(57, exists('#pace'))
	Assert_True(58, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		# 7/15
	Assert_Equal(63, 0, Get_Chars())
	Assert_True(59, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	Assert_Equal(64, 2, Get_Chars())
	Assert_True(60, exists('#pace#InsertEnter#*'))
	Assert_Equal(545, 12, pace.carry)
	Assert_Equal(546, 14, Get_Parts())
	doautocmd pace InsertEnter		# 7/16: Discard rejects.
	Assert_Equal(547, 12, pace.carry)
	Assert_Equal(548, 12, Get_Parts())
	Assert_Equal(65, 0x10000, and(pace.policy, 0x10030))
	Assert_Equal(66, 12, pace.dump[0][0][2])
	Assert_Equal(67, (pace.dump[0][0][0] + 9), pace.dump[0][0][1])
	Assert_True(61, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		# 8/16: Keep null.
	Assert_Equal(549, 12, pace.carry)
	Assert_Equal(550, 12, Get_Parts())
	Assert_Equal(68, (pace.dump[0][0][0] + 8), pace.dump[0][0][1])


	unlet! g:pace_policy
	g:pace_policy = 10117

	Assert_True(62, !exists('#pace#InsertLeave#*'))
	Assert_Equal(69, -1, Get_Chars())
	Assert_True(63, exists('#pace'))
	Assert_True(64, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		# 8/17
	Assert_Equal(70, 0, Get_Chars())
	Assert_True(65, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	Assert_Equal(71, 2, Get_Chars())
	Assert_True(66, exists('#pace#InsertLeave#*'))
	Assert_Equal(551, 12, pace.carry)
	Assert_Equal(552, 14, Get_Parts())
	doautocmd pace InsertLeave		# 9/17: Update the count.
	Assert_Equal(553, 14, pace.carry)
	Assert_Equal(554, 14, Get_Parts())
	Assert_Equal(72, 14, pace.dump[0][0][2])
	Assert_Equal(73, (pace.dump[0][0][0] + 8), pace.dump[0][0][1])

	Assert_True(67, !exists('#pace#InsertLeave#*'))
	Assert_Equal(74, -1, Get_Chars())
	Assert_True(68, exists('#pace'))
	Assert_True(69, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		# 9/18
	Assert_Equal(75, 0, Get_Chars())
	Assert_True(70, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		# 10/18: Keep null.
	Assert_Equal(555, 14, pace.carry)
	Assert_Equal(556, 14, Get_Parts())
	Assert_Equal(76, 0x10100, and(pace.policy, 0x10100))
	Assert_Equal(77, 14, pace.dump[0][0][2])
	Assert_Equal(78, (pace.dump[0][0][0] + 8), pace.dump[0][0][1])

	Assert_True(71, !exists('#pace#InsertLeave#*'))
	Assert_Equal(79, -1, Get_Chars())
	Assert_True(72, exists('#pace'))
	Assert_True(73, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		# 10/19
	Assert_Equal(80, 0, Get_Chars())
	Assert_True(74, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	Assert_Equal(81, 2, Get_Chars())
	Assert_True(75, exists('#pace#InsertEnter#*'))
	Assert_Equal(557, 14, pace.carry)
	Assert_Equal(558, 16, Get_Parts())
	doautocmd pace InsertEnter		# 11/20: Keep rejects.
	Assert_Equal(559, 16, pace.carry)
	Assert_Equal(560, 16, Get_Parts())
	Assert_Equal(82, 0x10010, and(pace.policy, 0x10010))
	Assert_Equal(83, 16, pace.dump[0][0][2])
	Assert_Equal(84, (pace.dump[0][0][0] + 9), pace.dump[0][0][1])
	Assert_True(76, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		# 12/20: Keep null.
	Assert_Equal(561, 16, pace.carry)
	Assert_Equal(562, 16, Get_Parts())
	Assert_Equal(85, (pace.dump[0][0][0] + 8), pace.dump[0][0][1])


	unlet! g:pace_policy
	g:pace_policy = 10127

	Assert_True(77, !exists('#pace#InsertLeave#*'))
	Assert_Equal(86, -1, Get_Chars())
	Assert_True(78, exists('#pace'))
	Assert_True(79, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		# 12/21
	Assert_Equal(87, 0, Get_Chars())
	Assert_True(80, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	Assert_Equal(88, 2, Get_Chars())
	Assert_True(81, exists('#pace#InsertLeave#*'))
	Assert_Equal(563, 16, pace.carry)
	Assert_Equal(564, 18, Get_Parts())
	doautocmd pace InsertLeave		# 13/21: Update the count.
	Assert_Equal(565, 18, pace.carry)
	Assert_Equal(566, 18, Get_Parts())
	Assert_Equal(89, 18, pace.dump[0][0][2])
	Assert_Equal(90, (pace.dump[0][0][0] + 8), pace.dump[0][0][1])

	Assert_True(82, !exists('#pace#InsertLeave#*'))
	Assert_Equal(91, -1, Get_Chars())
	Assert_True(83, exists('#pace'))
	Assert_True(84, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		# 13/22
	Assert_Equal(92, 0, Get_Chars())
	Assert_True(85, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		# 14/22: Keep null.
	Assert_Equal(567, 18, pace.carry)
	Assert_Equal(568, 18, Get_Parts())
	Assert_Equal(93, 0x10100, and(pace.policy, 0x10100))
	Assert_Equal(94, 18, pace.dump[0][0][2])
	Assert_Equal(95, (pace.dump[0][0][0] + 8), pace.dump[0][0][1])

	Assert_True(86, !exists('#pace#InsertLeave#*'))
	Assert_Equal(96, -1, Get_Chars())
	Assert_True(87, exists('#pace'))
	Assert_True(88, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter		# 14/23
	Assert_Equal(97, 0, Get_Chars())
	Assert_True(89, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	Assert_Equal(98, 2, Get_Chars())
	Assert_True(90, exists('#pace#InsertEnter#*'))
	Assert_Equal(569, 18, pace.carry)
	Assert_Equal(570, 20, Get_Parts())
	doautocmd pace InsertEnter		# 15/24: Mark rejects.
	Assert_Equal(571, 20, pace.carry)
	Assert_Equal(572, 20, Get_Parts())
	Assert_Equal(99, 0x10020, and(pace.policy, 0x10020))
	Assert_Equal(100, 20, pace.dump[0][0][2])
	Assert_Equal(101, (pace.dump[0][0][0] + 9), pace.dump[0][0][1])
	Assert_True(91, pace.dump[bufnr('%')][-1][0] < 0)
	Assert_True(92, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave		# 16/24: Keep null.
	Assert_Equal(573, 20, pace.carry)
	Assert_Equal(574, 20, Get_Parts())
	Assert_Equal(102, (pace.dump[0][0][0] + 8), pace.dump[0][0][1])
	mockup.mode = 'n'
	const test_2: number = Pace_Load(0)

	const test_3: number = Pace_Load(1)
	mockup.mode = 'i'
	const test_updatetime: number = &updatetime
	&updatetime = Pace.sample_above - 2 * Pace.sample_below
	unlet! g:pace_sample
	Assert_True(93, pace.sample_in < Pace.sample_below)
	var test_sample_in: number

	try
		g:pace_sample = Pace.sample_above - Pace.sample_below
		test_sample_in = pace.sample_in
		doautocmd pace InsertEnter
		Assert_Not_Equal(2, pace.sample_in, test_sample_in)
		Assert_Not_Equal(3, &updatetime, pace.state.updatetime)
		Assert_Equal(103, &updatetime, pace.sample_in)

		g:pace_sample = Pace.sample_above + 1
		test_sample_in = pace.sample_in
		doautocmd pace InsertEnter
		Assert_Not_Equal(4, pace.sample_in, test_sample_in)
		Assert_Not_Equal(5, &updatetime, pace.sample_in)
		Assert_Equal(104, &updatetime, pace.state.updatetime)

		g:pace_sample = Pace.sample_below - 1
		test_sample_in = pace.sample_in
		doautocmd pace InsertEnter
		Assert_Not_Equal(6, pace.sample_in, test_sample_in)
		Assert_Not_Equal(7, &updatetime, pace.sample_in)
		Assert_Equal(105, &updatetime, pace.state.updatetime)

		g:pace_sample = Pace.sample_above - Pace.sample_below
		test_sample_in = pace.sample_in
		doautocmd pace InsertEnter
		Assert_Not_Equal(8, pace.sample_in, test_sample_in)
		Assert_Not_Equal(9, &updatetime, pace.state.updatetime)
		Assert_Equal(106, &updatetime, pace.sample_in)

		g:pace_sample = Pace.sample_above - 2 * Pace.sample_below
		test_sample_in = pace.sample_in
		doautocmd pace InsertEnter
		Assert_Not_Equal(10, pace.sample_in, test_sample_in)
		Assert_Not_Equal(11, &updatetime, pace.state.updatetime)
		Assert_Equal(107, &updatetime, pace.sample_in)
	finally
		&updatetime = test_updatetime
	endtry

	mockup.mode = 'n'
	const test_4: number = Pace_Load(0)
finally
	mockup.mode = test_mode
endtry

quit
#####################################|EOF|####################################

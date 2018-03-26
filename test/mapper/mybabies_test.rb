{
	dbType: "mysql",
	mapper: {
		# namespace: "com.ztesoft.bss.smart.mapper.operationMonitor.ServListManageMapper",
		select: {
			getPerson: {
					# id: "getPerson",
					resultType: "String",
					sql: %Q{
						select
							id
						from
							person p, class c
						where
							name = #{person_name}
							and
							person.class_id = class.class_id
						#{common3}
						#{
							mb_if(%Q{order_by}) {
								%Q{""}
							}
						}
					}
			},

			ifTest1: {
				sql: %Q{
					#{
						mb_if(%Q{id == '10000'}) {
							%Q{select person_name from person where id = #{id}}
						}
					}

				}
			},

			forEachTest1: {
				sql: %Q{
					select
					#{
						mb_foreach(%Q{
							{
								collection: column_names,
								seperator: ','
							}
						}) {
							%Q{
								#{mb_item}
							}
						}
					}
					from person
				}
			}
		},

		update: {

		},

		sql: {
			common1: %Q{ and 1=1},
			common2: %Q{and gender='male'},
			common3: "#{common1} #{common2}",
			# common4: %Q{
			# 	#{
			# 		mb_foreach(item) {
			# 			%Q{union select #{person_name}}
			# 		}
			# 	}
			# 	;
			# },
			# common5: %Q{
			# 	and 1=1
			# 	#{
			# 		mb_if(is_test) {
			# 			%Q{
			# 				desc
			# 				#{common4}
			# 			}
			# 		}
			# 	}
			# }
		},

	}
}


# where
# 	id = #{id}
# #{common_sql_1}
# MyBabies
MyBabies is a sql mapper framework that acts like MyBatis framework, while MyBabies use Ruby Hash literal (something like JSON) instead of XML to wrap sql statement. And also, it is implemented by Ruby language.


```ruby
{
	dbType: "mysql",
	mapper: {
		select: {
			getPerson: {
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
								%Q{" order by id"}
							}
						}
					}
			},
		},

		sql: {
			common1: %Q{ and 1=1},
			common2: %Q{and gender='male'},
			common3: "#{common1} #{common2}",
		},

	}
}
```

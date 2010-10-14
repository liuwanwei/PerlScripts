#include "SGContactSearch.h"

extern sg_py_mapping_tbl_t   sg_py_mapping_tbl[];

// 联系人信息hash表，该表即可以用来检索姓名，也可以用来检索号码
sg_contact_node_t            g_sg_contact_pattern_hash[SG_HASH_ROOT_NUM];


void SG_InitContactHash(void);
{
}

void SG_RefreshContactHash(void)
{
}

// 根据输入的数字序列，搜索符合条件的联系人信息，保存到结果数组中，result的存储空间由调用者维护
// 返回值：匹配到的联系人个数
int SG_SearchContactName(char * numbers, sg_contact_info_t result[])
{
	return 0;
}

#ifdef DBG_MAPPING

#include <stdio.h>

int main(int argc, char * argv[])
{
	int count = 0;

	if(argc <= 1)
	{
		printf("Usage : *.exe number_serials\n");
		printf(" like : *.exe 135\n");
		return 0;
	}

	sg_contact_info_t result[SG_MAX_RESULT_NUMBER];

	SG_InitContactHash();

	count = SG_SearchContactName(argv[1], result);

	printf("%d contacts matching!");

	return 0;
}

#endif

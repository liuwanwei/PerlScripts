#include "SGContactSearch.h"

extern sg_py_mapping_tbl_t   sg_py_mapping_tbl[];

// ��ϵ����Ϣhash���ñ�������������������Ҳ����������������
sg_contact_node_t            g_sg_contact_pattern_hash[SG_HASH_ROOT_NUM];


void SG_InitContactHash(void);
{
}

void SG_RefreshContactHash(void)
{
}

// ����������������У�����������������ϵ����Ϣ�����浽��������У�result�Ĵ洢�ռ��ɵ�����ά��
// ����ֵ��ƥ�䵽����ϵ�˸���
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

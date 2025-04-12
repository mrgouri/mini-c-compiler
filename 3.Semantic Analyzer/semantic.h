#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct ScopeNode {
    char *value;
    struct ScopeNode *parent;
    struct ScopeNode *children[10]; // Assuming a node can have up to 10 children
    int numChildren;
} ScopeNode;

// Function to create a new scope node
ScopeNode* createScopeNode(char *value, ScopeNode *parent) {
    ScopeNode *node = (ScopeNode *)malloc(sizeof(ScopeNode));
    node->value = value;
    node->parent = parent;
    node->numChildren = 0;
    return node;
}

// Function to add a child to a scope node
ScopeNode* addChild(ScopeNode *cur_node) {
    int n = 2 + strlen(cur_node->value) + 1;
    char *temp = (char *)malloc(n * sizeof(char));
    strcpy(temp, cur_node->value);
    strcat(temp, "_");
    char temp2[10];
    sprintf(temp2, "%d", cur_node->numChildren + 1);
    strcat(temp, temp2);
    ScopeNode *child = createScopeNode(temp, cur_node);
    if (cur_node->numChildren < 10) {
        cur_node->children[cur_node->numChildren++] = child;
    } else {
        printf("Error: Maximum number of children reached for this node.\n");
    }
    return child;
}

// Function to move back to the parent scope
ScopeNode* backup(ScopeNode *cur_node) {
    if (!cur_node) {
        cur_node = (ScopeNode *)malloc(sizeof(ScopeNode));
        cur_node->value = "1";
    }
    cur_node = cur_node->parent;
    return cur_node;
}

// Function to get the current scope value
char* getScopeValue(ScopeNode *currentScope) {
    return currentScope->value;
}

// Function to print the value of a scope node
void print(ScopeNode *node) {
    printf("%s\n", node->value);
}

// Function to check if a string exists in the switch array
int switch_check(char *str, char switch_array[][20], int switch_index) {
    for (int i = 0; i < 20; i++) {
        if (strcmp(str, switch_array[i]) == 0) {
            return 1;
        }
    }
    return 0;
}

// Function to insert a string into the switch array
void switch_insert(char *str, char switch_array[][20], int *switch_index) {
    strcpy(switch_array[*switch_index], str);
    (*switch_index)++;
}

package com.schepor.gita.presentation.admin

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import com.schepor.gita.presentation.theme.Spacing

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AdminScreen(
    viewModel: AdminViewModel = hiltViewModel()
) {
    val seedState by viewModel.seedState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Admin Panel") },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer,
                    titleContentColor = MaterialTheme.colorScheme.onPrimaryContainer
                )
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(Spacing.space16),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                text = "Seed Database",
                style = MaterialTheme.typography.headlineMedium,
                modifier = Modifier.padding(bottom = Spacing.space24)
            )

            if (seedState.isLoading) {
                CircularProgressIndicator(
                    modifier = Modifier.padding(Spacing.space16)
                )
                seedState.message?.let {
                    Text(
                        text = it,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                }
            } else {
                Button(
                    onClick = { viewModel.seedContent() },
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = Spacing.space32)
                ) {
                    Text("Seed Initial Content")
                }
            }

            Spacer(modifier = Modifier.height(Spacing.space24))

            seedState.message?.let {
                if (seedState.isSuccess) {
                    Text(
                        text = it,
                        style = MaterialTheme.typography.bodyLarge,
                        color = MaterialTheme.colorScheme.primary
                    )
                }
            }

            seedState.error?.let {
                Text(
                    text = it,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.error,
                    modifier = Modifier.padding(top = Spacing.space16)
                )
            }

            Spacer(modifier = Modifier.height(Spacing.space32))

            Text(
                text = "⚠️ Warning: Only use this once to seed initial content",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
            )
        }
    }
}

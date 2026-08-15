package com.alafteknoloji.photon.features.settings

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material3.Divider
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.alafteknoloji.photon.core.designsystem.PhotonColors
import com.alafteknoloji.photon.core.designsystem.PhotonCornerRadius
import com.alafteknoloji.photon.core.designsystem.PhotonSpacing
import com.alafteknoloji.photon.core.designsystem.PhotonTypography

/**
 * Membership selection and tier presentation view for Free and upcoming Pro tiers.
 * 100% Parity with iOS MembershipView.swift.
 */
@Composable
fun MembershipScreen(onDismiss: () -> Unit) {
    val scrollState = rememberScrollState()

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .verticalScroll(scrollState)
            .padding(horizontal = PhotonSpacing.lg)
            .padding(bottom = PhotonSpacing.xxl),
        verticalArrangement = Arrangement.spacedBy(PhotonSpacing.xl)
    ) {
        // Header Description
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = PhotonSpacing.sm),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(PhotonSpacing.xs)
        ) {
            Text(
                text = "Phonla Üyelikleri",
                style = PhotonTypography.titleLarge,
                color = PhotonColors.textPrimary
            )

            Text(
                text = "Fotoğraf düzenleme deneyiminizi bir üst seviyeye taşıyın.",
                style = PhotonTypography.bodyMedium,
                color = PhotonColors.textSecondary,
                textAlign = TextAlign.Center
            )
        }

        // Free Tier Card
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .shadow(2.dp, RoundedCornerShape(PhotonCornerRadius.lg))
                .clip(RoundedCornerShape(PhotonCornerRadius.lg))
                .background(PhotonColors.surfacePrimary)
                .border(1.dp, PhotonColors.border, RoundedCornerShape(PhotonCornerRadius.lg))
                .padding(PhotonSpacing.lg),
            verticalArrangement = Arrangement.spacedBy(PhotonSpacing.md)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(verticalArrangement = Arrangement.spacedBy(PhotonSpacing.xxs)) {
                    Text(
                        text = "Phonla Standart",
                        style = PhotonTypography.titleMedium,
                        color = PhotonColors.textPrimary
                    )
                    Text(
                        text = "Ücretsiz",
                        style = PhotonTypography.caption,
                        color = PhotonColors.textSecondary
                    )
                }

                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(PhotonCornerRadius.full))
                        .background(PhotonColors.surfaceSecondary)
                        .padding(horizontal = PhotonSpacing.sm, vertical = 4.dp)
                ) {
                    Text(
                        text = "Mevcut Plan",
                        style = PhotonTypography.caption.copy(fontWeight = FontWeight.SemiBold),
                        color = PhotonColors.textPrimary
                    )
                }
            }

            Divider(color = PhotonColors.divider)

            Column(verticalArrangement = Arrangement.spacedBy(PhotonSpacing.sm)) {
                FeatureItem("Işık & Renk ayarları (Pozlama, Sıcaklık vb.)", isIncluded = true)
                FeatureItem("Sinematik Görünüm & Film önayarları", isIncluded = true)
                FeatureItem("Profesyonel Monochrome tonlama motoru", isIncluded = true)
                FeatureItem("Tam çözünürlüklü kayıpsız dışa aktarma", isIncluded = true)
                FeatureItem("Donanım hızlandırmalı on-device gizlilik", isIncluded = true)
            }
        }

        // Pro Tier Card (Upcoming)
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .shadow(12.dp, RoundedCornerShape(PhotonCornerRadius.lg))
                .clip(RoundedCornerShape(PhotonCornerRadius.lg))
                .background(Color.Black)
                .padding(PhotonSpacing.lg),
            verticalArrangement = Arrangement.spacedBy(PhotonSpacing.md)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(verticalArrangement = Arrangement.spacedBy(PhotonSpacing.xxs)) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(PhotonSpacing.xs)
                    ) {
                        Text(
                            text = "Phonla Pro",
                            style = PhotonTypography.titleMedium,
                            color = PhotonColors.textInverted
                        )
                        Icon(
                            imageVector = Icons.Default.AutoAwesome,
                            contentDescription = null,
                            tint = Color(0xFFFFD700),
                            modifier = Modifier.size(16.dp)
                        )
                    }
                    Text(
                        text = "Yakında",
                        style = PhotonTypography.caption,
                        color = PhotonColors.textInverted.copy(alpha = 0.8f)
                    )
                }

                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(PhotonCornerRadius.full))
                        .background(Color(0xFFFFD700))
                        .padding(horizontal = PhotonSpacing.sm, vertical = 4.dp)
                ) {
                    Text(
                        text = "Geliştiriliyor",
                        style = PhotonTypography.caption.copy(fontWeight = FontWeight.SemiBold),
                        color = Color.Black
                    )
                }
            }

            Divider(color = Color.White.copy(alpha = 0.2f))

            Text(
                text = "Yakında: AI Otomatik Düzenleme ve gelişmiş özellikler",
                style = PhotonTypography.bodyMedium.copy(fontWeight = FontWeight.Medium),
                color = PhotonColors.textInverted
            )

            Column(verticalArrangement = Arrangement.spacedBy(PhotonSpacing.sm)) {
                FeatureItem("Yapay Zeka ile Otomatik Renk & Işık İyileştirme", isIncluded = true, isInverted = true)
                FeatureItem("Özel 3D LUT ve Film Emülasyonu Desteği", isIncluded = true, isInverted = true)
                FeatureItem("Gelişmiş Renk Eğrileri (RGB Tone Curves)", isIncluded = true, isInverted = true)
                FeatureItem("Gelişmiş Bölgesel Maskeleme & Seçici Düzenleme", isIncluded = true, isInverted = true)
            }
        }
    }
}

@Composable
private fun FeatureItem(
    text: String,
    isIncluded: Boolean,
    isInverted: Boolean = false
) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(PhotonSpacing.sm)
    ) {
        Icon(
            imageVector = Icons.Default.CheckCircle,
            contentDescription = null,
            tint = if (isInverted) Color(0xFF34C759) else PhotonColors.textPrimary,
            modifier = Modifier.size(16.dp)
        )
        Text(
            text = text,
            style = PhotonTypography.caption,
            color = if (isInverted) PhotonColors.textInverted.copy(alpha = 0.9f) else PhotonColors.textSecondary
        )
    }
}

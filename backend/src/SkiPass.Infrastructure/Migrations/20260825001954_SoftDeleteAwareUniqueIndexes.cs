using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SkiPass.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class SoftDeleteAwareUniqueIndexes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Users_Email",
                table: "Users");

            migrationBuilder.DropIndex(
                name: "IX_Users_IdentityUserId",
                table: "Users");

            migrationBuilder.DropIndex(
                name: "IX_Trails_SkiResortId_Code",
                table: "Trails");

            migrationBuilder.DropIndex(
                name: "IX_TrailDifficulties_Name",
                table: "TrailDifficulties");

            migrationBuilder.DropIndex(
                name: "IX_TicketTypes_SkiResortId_Name",
                table: "TicketTypes");

            migrationBuilder.DropIndex(
                name: "IX_SkiResorts_Name",
                table: "SkiResorts");

            migrationBuilder.DropIndex(
                name: "IX_SkiLifts_SkiResortId_Code",
                table: "SkiLifts");

            migrationBuilder.DropIndex(
                name: "IX_Reviews_UserId_BenefitId",
                table: "Reviews");

            migrationBuilder.DropIndex(
                name: "IX_Reviews_UserId_SkiResortId",
                table: "Reviews");

            migrationBuilder.DropIndex(
                name: "IX_Reviews_UserId_TrailId",
                table: "Reviews");

            migrationBuilder.DropIndex(
                name: "IX_PaymentMethods_Code",
                table: "PaymentMethods");

            migrationBuilder.DropIndex(
                name: "IX_Partners_Name",
                table: "Partners");

            migrationBuilder.DropIndex(
                name: "IX_LiftTypes_Name",
                table: "LiftTypes");

            migrationBuilder.DropIndex(
                name: "IX_IncidentTypes_Name",
                table: "IncidentTypes");

            migrationBuilder.DropIndex(
                name: "IX_Countries_IsoCode",
                table: "Countries");

            migrationBuilder.DropIndex(
                name: "IX_Countries_Name",
                table: "Countries");

            migrationBuilder.DropIndex(
                name: "IX_Cities_CountryId_Name",
                table: "Cities");

            migrationBuilder.DropIndex(
                name: "IX_Benefits_SkiResortId_Name",
                table: "Benefits");

            migrationBuilder.DropIndex(
                name: "IX_BenefitCategories_Name",
                table: "BenefitCategories");

            migrationBuilder.DropIndex(
                name: "IX_AnnouncementCategories_Name",
                table: "AnnouncementCategories");

            migrationBuilder.CreateIndex(
                name: "IX_Users_Email",
                table: "Users",
                column: "Email",
                unique: true,
                filter: "[IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_Users_IdentityUserId",
                table: "Users",
                column: "IdentityUserId",
                unique: true,
                filter: "[IdentityUserId] IS NOT NULL AND [IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_Trails_SkiResortId_Code",
                table: "Trails",
                columns: new[] { "SkiResortId", "Code" },
                unique: true,
                filter: "[IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_TrailDifficulties_Name",
                table: "TrailDifficulties",
                column: "Name",
                unique: true,
                filter: "[IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_TicketTypes_SkiResortId_Name",
                table: "TicketTypes",
                columns: new[] { "SkiResortId", "Name" },
                unique: true,
                filter: "[IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_SkiResorts_Name",
                table: "SkiResorts",
                column: "Name",
                unique: true,
                filter: "[IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_SkiLifts_SkiResortId_Code",
                table: "SkiLifts",
                columns: new[] { "SkiResortId", "Code" },
                unique: true,
                filter: "[IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_UserId_BenefitId",
                table: "Reviews",
                columns: new[] { "UserId", "BenefitId" },
                unique: true,
                filter: "[BenefitId] IS NOT NULL AND [IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_UserId_SkiResortId",
                table: "Reviews",
                columns: new[] { "UserId", "SkiResortId" },
                unique: true,
                filter: "[SkiResortId] IS NOT NULL AND [IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_UserId_TrailId",
                table: "Reviews",
                columns: new[] { "UserId", "TrailId" },
                unique: true,
                filter: "[TrailId] IS NOT NULL AND [IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_PaymentMethods_Code",
                table: "PaymentMethods",
                column: "Code",
                unique: true,
                filter: "[IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_Partners_Name",
                table: "Partners",
                column: "Name",
                unique: true,
                filter: "[IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_LiftTypes_Name",
                table: "LiftTypes",
                column: "Name",
                unique: true,
                filter: "[IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_IncidentTypes_Name",
                table: "IncidentTypes",
                column: "Name",
                unique: true,
                filter: "[IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_Countries_IsoCode",
                table: "Countries",
                column: "IsoCode",
                unique: true,
                filter: "[IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_Countries_Name",
                table: "Countries",
                column: "Name",
                unique: true,
                filter: "[IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_Cities_CountryId_Name",
                table: "Cities",
                columns: new[] { "CountryId", "Name" },
                unique: true,
                filter: "[IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_Benefits_SkiResortId_Name",
                table: "Benefits",
                columns: new[] { "SkiResortId", "Name" },
                unique: true,
                filter: "[IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_BenefitCategories_Name",
                table: "BenefitCategories",
                column: "Name",
                unique: true,
                filter: "[IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_AnnouncementCategories_Name",
                table: "AnnouncementCategories",
                column: "Name",
                unique: true,
                filter: "[IsDeleted] = 0");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Users_Email",
                table: "Users");

            migrationBuilder.DropIndex(
                name: "IX_Users_IdentityUserId",
                table: "Users");

            migrationBuilder.DropIndex(
                name: "IX_Trails_SkiResortId_Code",
                table: "Trails");

            migrationBuilder.DropIndex(
                name: "IX_TrailDifficulties_Name",
                table: "TrailDifficulties");

            migrationBuilder.DropIndex(
                name: "IX_TicketTypes_SkiResortId_Name",
                table: "TicketTypes");

            migrationBuilder.DropIndex(
                name: "IX_SkiResorts_Name",
                table: "SkiResorts");

            migrationBuilder.DropIndex(
                name: "IX_SkiLifts_SkiResortId_Code",
                table: "SkiLifts");

            migrationBuilder.DropIndex(
                name: "IX_Reviews_UserId_BenefitId",
                table: "Reviews");

            migrationBuilder.DropIndex(
                name: "IX_Reviews_UserId_SkiResortId",
                table: "Reviews");

            migrationBuilder.DropIndex(
                name: "IX_Reviews_UserId_TrailId",
                table: "Reviews");

            migrationBuilder.DropIndex(
                name: "IX_PaymentMethods_Code",
                table: "PaymentMethods");

            migrationBuilder.DropIndex(
                name: "IX_Partners_Name",
                table: "Partners");

            migrationBuilder.DropIndex(
                name: "IX_LiftTypes_Name",
                table: "LiftTypes");

            migrationBuilder.DropIndex(
                name: "IX_IncidentTypes_Name",
                table: "IncidentTypes");

            migrationBuilder.DropIndex(
                name: "IX_Countries_IsoCode",
                table: "Countries");

            migrationBuilder.DropIndex(
                name: "IX_Countries_Name",
                table: "Countries");

            migrationBuilder.DropIndex(
                name: "IX_Cities_CountryId_Name",
                table: "Cities");

            migrationBuilder.DropIndex(
                name: "IX_Benefits_SkiResortId_Name",
                table: "Benefits");

            migrationBuilder.DropIndex(
                name: "IX_BenefitCategories_Name",
                table: "BenefitCategories");

            migrationBuilder.DropIndex(
                name: "IX_AnnouncementCategories_Name",
                table: "AnnouncementCategories");

            migrationBuilder.CreateIndex(
                name: "IX_Users_Email",
                table: "Users",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Users_IdentityUserId",
                table: "Users",
                column: "IdentityUserId",
                unique: true,
                filter: "[IdentityUserId] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_Trails_SkiResortId_Code",
                table: "Trails",
                columns: new[] { "SkiResortId", "Code" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_TrailDifficulties_Name",
                table: "TrailDifficulties",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_TicketTypes_SkiResortId_Name",
                table: "TicketTypes",
                columns: new[] { "SkiResortId", "Name" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_SkiResorts_Name",
                table: "SkiResorts",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_SkiLifts_SkiResortId_Code",
                table: "SkiLifts",
                columns: new[] { "SkiResortId", "Code" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_UserId_BenefitId",
                table: "Reviews",
                columns: new[] { "UserId", "BenefitId" },
                unique: true,
                filter: "[BenefitId] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_UserId_SkiResortId",
                table: "Reviews",
                columns: new[] { "UserId", "SkiResortId" },
                unique: true,
                filter: "[SkiResortId] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_UserId_TrailId",
                table: "Reviews",
                columns: new[] { "UserId", "TrailId" },
                unique: true,
                filter: "[TrailId] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_PaymentMethods_Code",
                table: "PaymentMethods",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Partners_Name",
                table: "Partners",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_LiftTypes_Name",
                table: "LiftTypes",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_IncidentTypes_Name",
                table: "IncidentTypes",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Countries_IsoCode",
                table: "Countries",
                column: "IsoCode",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Countries_Name",
                table: "Countries",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Cities_CountryId_Name",
                table: "Cities",
                columns: new[] { "CountryId", "Name" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Benefits_SkiResortId_Name",
                table: "Benefits",
                columns: new[] { "SkiResortId", "Name" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_BenefitCategories_Name",
                table: "BenefitCategories",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_AnnouncementCategories_Name",
                table: "AnnouncementCategories",
                column: "Name",
                unique: true);
        }
    }
}

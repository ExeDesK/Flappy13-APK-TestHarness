.class public final Lcom/dotgears/flappy/TestHarness;
.super Ljava/lang/Object;

.field private static sEnabled:Z
.field private static sSeed:I
.field private static sStarted:Z
.field private static sTick:I
.field private static sTaps:Ljava/util/HashSet;

.method static constructor <clinit>()V
    .locals 1

    new-instance v0, Ljava/util/HashSet;
    invoke-direct {v0}, Ljava/util/HashSet;-><init>()V
    sput-object v0, Lcom/dotgears/flappy/TestHarness;->sTaps:Ljava/util/HashSet;

    const/4 v0, 0x0
    sput-boolean v0, Lcom/dotgears/flappy/TestHarness;->sEnabled:Z
    sput-boolean v0, Lcom/dotgears/flappy/TestHarness;->sStarted:Z
    sput v0, Lcom/dotgears/flappy/TestHarness;->sTick:I

    return-void
.end method

.method private constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

.method public static init(Landroid/app/Activity;)V
    .locals 8

    const/4 v0, 0x0
    sput-boolean v0, Lcom/dotgears/flappy/TestHarness;->sStarted:Z
    sput v0, Lcom/dotgears/flappy/TestHarness;->sTick:I

    sget-object v1, Lcom/dotgears/flappy/TestHarness;->sTaps:Ljava/util/HashSet;
    invoke-virtual {v1}, Ljava/util/HashSet;->clear()V

    invoke-virtual {p0}, Landroid/app/Activity;->getIntent()Landroid/content/Intent;
    move-result-object v1

    const-string v2, "flappy_test"
    invoke-virtual {v1, v2, v0}, Landroid/content/Intent;->getBooleanExtra(Ljava/lang/String;Z)Z
    move-result v2
    sput-boolean v2, Lcom/dotgears/flappy/TestHarness;->sEnabled:Z

    if-nez v2, :enabled
    return-void

:enabled
    const-string v2, "flappy_seed"
    const v3, 0x075bcd15
    invoke-virtual {v1, v2, v3}, Landroid/content/Intent;->getIntExtra(Ljava/lang/String;I)I
    move-result v2
    sput v2, Lcom/dotgears/flappy/TestHarness;->sSeed:I

    const-string v2, "flappy_taps"
    invoke-virtual {v1, v2}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2

    if-nez v2, :have_taps
    const-string v2, ""

:have_taps
    invoke-virtual {v2}, Ljava/lang/String;->length()I
    move-result v3
    if-lez v3, :parsed

    const-string v3, ","
    invoke-virtual {v2, v3}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;
    move-result-object v2

    array-length v3, v2
    const/4 v4, 0x0

:parse_loop
    if-ge v4, v3, :parsed

    aget-object v5, v2, v4
    invoke-virtual {v5}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v5
    invoke-virtual {v5}, Ljava/lang/String;->length()I
    move-result v6
    if-lez v6, :parse_next

    invoke-static {v5}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I
    move-result v6
    invoke-static {v6}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;
    move-result-object v6
    sget-object v7, Lcom/dotgears/flappy/TestHarness;->sTaps:Ljava/util/HashSet;
    invoke-virtual {v7, v6}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z

:parse_next
    add-int/lit8 v4, v4, 0x1
    goto :parse_loop

:parsed
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    const-string v3, "CONFIG,seed="
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    sget v3, Lcom/dotgears/flappy/TestHarness;->sSeed:I
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v3, ",taps="
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    sget-object v3, Lcom/dotgears/flappy/TestHarness;->sTaps:Ljava/util/HashSet;
    invoke-virtual {v3}, Ljava/util/HashSet;->size()I
    move-result v3
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2
    invoke-static {v2}, Lcom/dotgears/flappy/TestHarness;->log(Ljava/lang/String;)V

    return-void
.end method

.method public static seed(I)I
    .locals 1
    sget-boolean v0, Lcom/dotgears/flappy/TestHarness;->sEnabled:Z
    if-eqz v0, :original
    sget v0, Lcom/dotgears/flappy/TestHarness;->sSeed:I
    return v0
:original
    return p0
.end method

.method public static beforeTick(Lcom/dotgears/flappy/c;)V
    .locals 4

    sget-boolean v0, Lcom/dotgears/flappy/TestHarness;->sEnabled:Z
    if-nez v0, :enabled
    return-void

:enabled
    sget-boolean v0, Lcom/dotgears/flappy/TestHarness;->sStarted:Z
    if-nez v0, :maybe_tap

    iget-boolean v0, p0, Lcom/dotgears/flappy/c;->H:Z
    if-eqz v0, :not_title
    return-void

:not_title
    iget-object v0, p0, Lcom/dotgears/flappy/c;->al:Lcom/dotgears/flappy/f;
    if-nez v0, :have_ready
    return-void

:have_ready
    iget v0, v0, Lcom/dotgears/flappy/f;->d:I
    const/4 v1, 0x1
    if-eq v0, v1, :ready_settled
    return-void

:ready_settled
    iget-object v0, p0, Lcom/dotgears/flappy/c;->J:Lcom/dotgears/flappy/a;
    iget-boolean v0, v0, Lcom/dotgears/flappy/a;->w:Z
    if-nez v0, :start_trace
    return-void

:start_trace
    const/4 v0, 0x1
    sput-boolean v0, Lcom/dotgears/flappy/TestHarness;->sStarted:Z
    const/4 v0, 0x0
    sput v0, Lcom/dotgears/flappy/TestHarness;->sTick:I

    const-string v0, "H,tick,birdX,birdY,velY,rotation,rotVel,rotAccel,gravity,hit,idle,score,landX,p1x,p1y,p2x,p2y,p3x,p3y,speed,warmup,rngY,rngZ"
    invoke-static {v0}, Lcom/dotgears/flappy/TestHarness;->log(Ljava/lang/String;)V

    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "START,seed="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    sget v1, Lcom/dotgears/flappy/TestHarness;->sSeed:I
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v1, ",rngY="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    sget v1, Lcom/dotgears/j;->y:I
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v1, ",rngZ="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    sget v1, Lcom/dotgears/j;->z:I
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-static {v0}, Lcom/dotgears/flappy/TestHarness;->log(Ljava/lang/String;)V

:maybe_tap
    sget-object v0, Lcom/dotgears/flappy/TestHarness;->sTaps:Ljava/util/HashSet;
    sget v1, Lcom/dotgears/flappy/TestHarness;->sTick:I
    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;
    move-result-object v2
    invoke-virtual {v0, v2}, Ljava/util/HashSet;->contains(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :done

    # Use a neutral in-game coordinate. (0,0) overlaps the hidden pause
    # button hitbox because that sprite keeps its default position at 0,0.
    const/16 v0, 0x90
    const/16 v2, 0x100
    invoke-virtual {p0, v0, v2}, Lcom/dotgears/flappy/c;->a(II)V

    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "I,"
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-static {v0}, Lcom/dotgears/flappy/TestHarness;->log(Ljava/lang/String;)V

:done
    return-void
.end method

.method public static afterTick(Lcom/dotgears/flappy/c;)V
    .locals 4

    sget-boolean v0, Lcom/dotgears/flappy/TestHarness;->sEnabled:Z
    if-eqz v0, :done
    sget-boolean v0, Lcom/dotgears/flappy/TestHarness;->sStarted:Z
    if-eqz v0, :done

    invoke-static {p0}, Lcom/dotgears/flappy/TestHarness;->logState(Lcom/dotgears/flappy/c;)V

    iget v0, p0, Lcom/dotgears/flappy/c;->ao:I
    if-nez v0, :advance

    iget-object v0, p0, Lcom/dotgears/flappy/c;->J:Lcom/dotgears/flappy/a;
    iget-boolean v0, v0, Lcom/dotgears/flappy/a;->w:Z
    if-nez v0, :advance

    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "END,"
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    sget v1, Lcom/dotgears/flappy/TestHarness;->sTick:I
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v1, ",score="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v1, p0, Lcom/dotgears/flappy/c;->y:I
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-static {v0}, Lcom/dotgears/flappy/TestHarness;->log(Ljava/lang/String;)V

    const/4 v0, 0x0
    sput-boolean v0, Lcom/dotgears/flappy/TestHarness;->sStarted:Z
    goto :done

:advance
    sget v0, Lcom/dotgears/flappy/TestHarness;->sTick:I
    add-int/lit8 v0, v0, 0x1
    sput v0, Lcom/dotgears/flappy/TestHarness;->sTick:I

:done
    return-void
.end method

.method private static logState(Lcom/dotgears/flappy/c;)V
    .locals 4

    iget-object v0, p0, Lcom/dotgears/flappy/c;->J:Lcom/dotgears/flappy/a;

    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "S,"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    sget v2, Lcom/dotgears/flappy/TestHarness;->sTick:I
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v2, ","
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v3, v0, Lcom/dotgears/flappy/a;->b:I
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v3, v0, Lcom/dotgears/flappy/a;->c:I
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v3, v0, Lcom/dotgears/flappy/a;->t:F
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v3, v0, Lcom/dotgears/flappy/a;->q:F
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v3, v0, Lcom/dotgears/flappy/a;->r:F
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v3, v0, Lcom/dotgears/flappy/a;->s:F
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v3, v0, Lcom/dotgears/flappy/a;->u:F
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget-boolean v3, v0, Lcom/dotgears/flappy/a;->v:Z
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget-boolean v3, v0, Lcom/dotgears/flappy/a;->w:Z
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v3, p0, Lcom/dotgears/flappy/c;->y:I
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v3, p0, Lcom/dotgears/flappy/c;->ac:I
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v3, p0, Lcom/dotgears/flappy/c;->ag:I
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v3, p0, Lcom/dotgears/flappy/c;->ad:I
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v3, p0, Lcom/dotgears/flappy/c;->ah:I
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v3, p0, Lcom/dotgears/flappy/c;->ae:I
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v3, p0, Lcom/dotgears/flappy/c;->ai:I
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v3, p0, Lcom/dotgears/flappy/c;->af:I
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v3, p0, Lcom/dotgears/flappy/c;->ao:I
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v3, p0, Lcom/dotgears/flappy/c;->ak:I
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    sget v3, Lcom/dotgears/j;->y:I
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    sget v3, Lcom/dotgears/j;->z:I
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-static {v1}, Lcom/dotgears/flappy/TestHarness;->log(Ljava/lang/String;)V

    return-void
.end method

.method private static log(Ljava/lang/String;)V
    .locals 1
    const-string v0, "Flappy13Trace"
    invoke-static {v0, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    return-void
.end method
